import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/database/app_database.dart';
import 'package:mori/core/error/failures.dart';
import 'package:mori/core/utils/result.dart';
import 'package:mori/features/pairing/data/datasources/pairing_local_data_source.dart';
import 'package:mori/features/sync/data/codec/sync_codec.dart';
import 'package:mori/features/sync/data/datasources/sync_local_data_source.dart';
import 'package:mori/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:mori/features/sync/domain/entities/box_state.dart';
import 'package:mori/features/sync/domain/entities/sync_outcome.dart';
import 'package:mori/features/sync/domain/entities/sync_payload.dart';

import '../../../helpers/fake_clock.dart';

T _ok<T>(Result<T> r) => switch (r) {
      Ok<T>(:final value) => value,
      Err<T>(:final failure) => fail('expected Ok, got Err($failure)'),
    };

Failure _err<T>(Result<T> r) => switch (r) {
      Err<T>(:final failure) => failure,
      Ok<T>() => fail('expected Err, got Ok'),
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SyncLocalDataSource local;
  late SyncRepositoryImpl repo;

  // Local device is slot A (pairingId 0xBEEF); partner is slot B.
  const localPairingId = 0xBEEF;
  const partnerInstallId = 0xAAAA;

  List<WireBoxState> statuses({int assigned = 0}) => [
        for (var day = 1; day <= 365; day++)
          day <= assigned ? WireBoxState.assigned : WireBoxState.free,
      ];

  String partnerSync({
    required int stateVersion,
    int installId = partnerInstallId,
    int assigned = 0,
  }) =>
      SyncCodec.encodeSync(SyncSnapshot(
        pairingId: localPairingId,
        slot: 1, // partner is slot B
        installId: installId,
        stateVersion: stateVersion,
        startEpochDay: 20000,
        statuses: statuses(assigned: assigned),
      ));

  Future<int> partnerRowCount() async =>
      (await local.readPartnerBoxes()).length;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    local = SyncLocalDataSource(db);
    repo = SyncRepositoryImpl(
      local,
      FakeClock(DateTime(2026, 8, 30)),
      Random(1),
    );
    // Seed a local challenge as slot A.
    await PairingLocalDataSource(db).seedChallenge(
      pairingId: localPairingId,
      localSlot: 0,
      localInstallId: 0x1111,
      localName: 'Yo',
      startEpochDay: 20000,
      createdAtMillis: 0,
    );
  });

  tearDown(() => db.close());

  group('acceptance rule (§8) — tasks 6.2, 6.4', () {
    test('first sync ever is accepted', () async {
      final outcome = _ok(await repo.applySyncPayload(
        partnerSync(stateVersion: 3, assigned: 5),
      ));
      expect(outcome, isA<SyncApplied>());
      expect((outcome as SyncApplied).stateVersion, 3);
      expect(await partnerRowCount(), 365);
    });

    test('idempotence: applying the same payload twice leaves the base '
        'identical', () async {
      final text = partnerSync(stateVersion: 3, assigned: 5);
      _ok(await repo.applySyncPayload(text));
      final boxesAfterFirst = await local.readPartnerBoxes();
      final snapAfterFirst = await local.readPartnerSnapshot();

      final second = _ok(await repo.applySyncPayload(text));
      expect(second, isA<SyncNoChange>());

      final boxesAfterSecond = await local.readPartnerBoxes();
      final snapAfterSecond = await local.readPartnerSnapshot();
      expect(boxesAfterSecond.map((b) => b.status).toList(),
          boxesAfterFirst.map((b) => b.status).toList());
      expect(snapAfterSecond!.stateVersion, snapAfterFirst!.stateVersion);
      expect(snapAfterSecond.receivedAtMillis, snapAfterFirst.receivedAtMillis);
    });

    test('monotonicity: a lower stateVersion writes nothing', () async {
      _ok(await repo.applySyncPayload(
        partnerSync(stateVersion: 5, assigned: 10),
      ));
      final before = await local.readPartnerBoxes();

      final stale = await repo.applySyncPayload(
        partnerSync(stateVersion: 4, assigned: 1),
      );
      expect(_err(stale), isA<StaleSnapshot>());

      final after = await local.readPartnerBoxes();
      expect(after.map((b) => b.status).toList(),
          before.map((b) => b.status).toList());
    });

    test('higher stateVersion is accepted', () async {
      _ok(await repo.applySyncPayload(partnerSync(stateVersion: 2)));
      final outcome =
          _ok(await repo.applySyncPayload(partnerSync(stateVersion: 7)));
      expect(outcome, isA<SyncApplied>());
      expect((outcome as SyncApplied).stateVersion, 7);
    });

    test('different installId accepts even when the version drops, and '
        'resets the baseline', () async {
      _ok(await repo.applySyncPayload(
        partnerSync(stateVersion: 100, assigned: 50),
      ));
      // Reinstall: installId changes, version resets low, board smaller.
      final outcome = _ok(await repo.applySyncPayload(
        partnerSync(stateVersion: 1, installId: 0xBBBB, assigned: 2),
      ));
      expect(outcome, isA<SyncPartnerReset>());
      expect((outcome as SyncPartnerReset).lostProgress, isTrue);

      final snap = await local.readPartnerSnapshot();
      expect(snap!.installId, 0xBBBB);
      expect(snap.stateVersion, 1);
    });

    test('reinstall without loss does not flag lostProgress', () async {
      _ok(await repo.applySyncPayload(
        partnerSync(stateVersion: 100, assigned: 5),
      ));
      final outcome = _ok(await repo.applySyncPayload(
        partnerSync(stateVersion: 1, installId: 0xBBBB, assigned: 5),
      ));
      expect((outcome as SyncPartnerReset).lostProgress, isFalse);
    });
  });

  group('checks 8 & 9', () {
    test('foreign pairing is rejected', () async {
      final foreign = SyncCodec.encodeSync(SyncSnapshot(
        pairingId: 0x9999, // not ours
        slot: 1,
        installId: partnerInstallId,
        stateVersion: 1,
        startEpochDay: 20000,
        statuses: statuses(),
      ));
      expect(_err(await repo.applySyncPayload(foreign)), isA<ForeignPairing>());
    });

    test('own payload (same slot) is rejected', () async {
      final own = SyncCodec.encodeSync(SyncSnapshot(
        pairingId: localPairingId,
        slot: 0, // same as local
        installId: 0x1111,
        stateVersion: 1,
        startEpochDay: 20000,
        statuses: statuses(),
      ));
      expect(
          _err(await repo.applySyncPayload(own)), isA<OwnPayloadScanned>());
    });

    test('a rejected payload leaves no partial write', () async {
      final foreign = SyncCodec.encodeSync(SyncSnapshot(
        pairingId: 0x9999,
        slot: 1,
        installId: partnerInstallId,
        stateVersion: 1,
        startEpochDay: 20000,
        statuses: statuses(assigned: 10),
      ));
      await repo.applySyncPayload(foreign);
      expect(await partnerRowCount(), 0);
      expect(await local.readPartnerSnapshot(), isNull);
    });

    test('PartnerBoxes is always 0 or 365 rows (I5)', () async {
      expect(await partnerRowCount(), 0);
      _ok(await repo.applySyncPayload(partnerSync(stateVersion: 1)));
      expect(await partnerRowCount(), 365);
    });
  });
}
