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

  const senderInstallId = 0x99AABBCCDDEEFF00;

  // A RESTORE emitted by the partner (slot B) to restore slot A.
  String restorePayload() {
    final statuses = [
      for (var day = 1; day <= 365; day++)
        day == 1
            ? WireBoxState.paid
            : day == 45
            ? WireBoxState.assigned
            : day == 365
            ? WireBoxState.paid
            : WireBoxState.free,
    ];
    return SyncCodec.encodeRestore(
      RestorePayload(
        pairingId: 0x0BADC0DE,
        senderSlot: 1,
        senderInstallId: senderInstallId,
        restoredStateVersion: 127,
        startEpochDay: 20696,
        snapshotEpochDay: 20690,
        senderName: 'Andrea',
        statuses: statuses,
      ),
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = SyncLocalDataSource(db);
    repo = SyncRepositoryImpl(
      local,
      // "today" = epoch day 20696, snapshot at 20690 -> 6 days stale.
      FakeClock(DateTime(1970).add(const Duration(days: 20696))),
      Random(1),
    );
  });

  tearDown(() => db.close());

  group('BuildRestorePayload (§5.2) — task 6.9: read-only', () {
    Future<void> seedLocal() => PairingLocalDataSource(db).seedChallenge(
      pairingId: 0x0BADC0DE,
      localSlot: 0,
      localInstallId: 0x1111,
      localName: 'Yo',
      startEpochDay: 20696,
      createdAtMillis: 0,
    );

    test('NothingToRestore when no partner snapshot is stored', () async {
      await seedLocal();
      expect(_err(await repo.buildRestorePayload()), isA<NothingToRestore>());
    });

    test(
      'builds a payload without touching any table or bumping stateVersion',
      () async {
        await seedLocal();
        // Give the partner replica some content to read back.
        await local.applySnapshot(
          statuses: [
            for (var day = 1; day <= 365; day++)
              day <= 10 ? WireBoxState.assigned : WireBoxState.free,
          ],
          stateVersion: 42,
          installId: senderInstallId,
          startEpochDay: 20696,
          receivedAtMillis: 1_700_000_000_000,
        );

        final ownBefore = await local.readOwnBoxes();
        final partnerBefore = await local.readPartnerBoxes();
        final snapBefore = (await local.readPartnerSnapshot())!;
        final configBefore = (await local.readConfig())!;

        final text = _ok(await repo.buildRestorePayload());
        expect(text, isNotEmpty);

        final ownAfter = await local.readOwnBoxes();
        final partnerAfter = await local.readPartnerBoxes();
        final snapAfter = (await local.readPartnerSnapshot())!;
        final configAfter = (await local.readConfig())!;

        expect(
          ownAfter.map(
            (b) => (b.day, b.status, b.drawnAtMillis, b.paidAtMillis),
          ),
          ownBefore.map(
            (b) => (b.day, b.status, b.drawnAtMillis, b.paidAtMillis),
          ),
        );
        expect(
          partnerAfter.map((b) => (b.day, b.status)),
          partnerBefore.map((b) => (b.day, b.status)),
        );
        expect(snapAfter.stateVersion, snapBefore.stateVersion);
        expect(snapAfter.installId, snapBefore.installId);
        expect(snapAfter.receivedAtMillis, snapBefore.receivedAtMillis);
        expect(configAfter.stateVersion, configBefore.stateVersion);
        expect(configAfter.stateVersion, 0);
        expect(configAfter.localInstallId, configBefore.localInstallId);
      },
    );
  });

  group('RESTORE guard (§8.3) — task 6.11', () {
    test('with a challenge present, returns RestoreNotApplicable and writes '
        'nothing', () async {
      await PairingLocalDataSource(db).seedChallenge(
        pairingId: 0x0BADC0DE,
        localSlot: 0,
        localInstallId: 0x1111,
        localName: 'Yo',
        startEpochDay: 20696,
        createdAtMillis: 0,
      );
      final ownBefore = await local.readOwnBoxes();
      final configBefore = await local.readConfig();

      final result = await repo.applyRestorePayload(
        scannedText: restorePayload(),
        localName: 'Yo',
      );
      expect(_err(result), isA<RestoreNotApplicable>());

      final ownAfter = await local.readOwnBoxes();
      final configAfter = await local.readConfig();
      expect(
        ownAfter.map((b) => b.status).toList(),
        ownBefore.map((b) => b.status).toList(),
      );
      expect(configAfter!.localInstallId, configBefore!.localInstallId);
      expect(configAfter.stateVersion, configBefore.stateVersion);
    });
  });

  group('RESTORE apply (§8.3) — task 6.11', () {
    test(
      'with no config, seeds 365 boxes with correct states and null dates',
      () async {
        final outcome = _ok(
          await repo.applyRestorePayload(
            scannedText: restorePayload(),
            localName: 'Bruno',
          ),
        );
        expect(outcome, isA<RestoreApplied>());
        expect((outcome as RestoreApplied).daysStale, 6);

        final boxes = await local.readOwnBoxes();
        expect(boxes.length, 365);
        expect(boxes.firstWhere((b) => b.day == 1).status, 2); // paid
        expect(boxes.firstWhere((b) => b.day == 45).status, 1); // assigned
        expect(boxes.firstWhere((b) => b.day == 365).status, 2); // paid
        expect(boxes.firstWhere((b) => b.day == 2).status, 0); // free

        // Both dates null on every box.
        expect(boxes.every((b) => b.drawnAtMillis == null), isTrue);
        expect(boxes.every((b) => b.paidAtMillis == null), isTrue);
      },
    );

    test('the local installId differs from the sender installId', () async {
      _ok(
        await repo.applyRestorePayload(
          scannedText: restorePayload(),
          localName: 'Bruno',
        ),
      );
      final config = await local.readConfig();
      expect(config!.localInstallId, isNot(senderInstallId));
      expect(config.partnerInstallId, senderInstallId);
    });

    test('the local slot is the opposite of the sender slot', () async {
      _ok(
        await repo.applyRestorePayload(
          scannedText: restorePayload(),
          localName: 'Bruno',
        ),
      );
      final config = await local.readConfig();
      expect(config!.localSlot, 0); // sender was slot 1
      expect(config.stateVersion, 127); // adopted restoredStateVersion
      expect(config.partnerName, 'Andrea');
    });

    test(
      'PartnerBoxes and PartnerSnapshots stay empty after restoring',
      () async {
        _ok(
          await repo.applyRestorePayload(
            scannedText: restorePayload(),
            localName: 'Bruno',
          ),
        );
        expect(await local.readPartnerBoxes(), isEmpty);
        expect(await local.readPartnerSnapshot(), isNull);
      },
    );
  });
}
