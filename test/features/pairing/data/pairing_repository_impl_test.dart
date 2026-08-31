import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/database/app_database.dart';
import 'package:mori/core/utils/result.dart';
import 'package:mori/features/pairing/data/datasources/pairing_local_data_source.dart';
import 'package:mori/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:mori/features/pairing/domain/entities/pair_invite.dart';
import 'package:mori/features/pairing/domain/entities/pairing_state.dart';
import 'package:mori/features/pairing/domain/repositories/pairing_repository.dart';

import '../../../helpers/fake_clock.dart';

T _ok<T>(Result<T> r) => switch (r) {
  Ok<T>(:final value) => value,
  Err<T>(:final failure) => fail('expected Ok, got Err($failure)'),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PairingRepositoryImpl repo;
  late FakeClock clock;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FakeClock(DateTime(2026, 8, 30));
    repo = PairingRepositoryImpl(
      PairingLocalDataSource(db),
      clock,
      Random(1234),
    );
  });

  tearDown(() => db.close());

  group('createChallenge (task 4.2)', () {
    test('seeds exactly 365 boxes, all free, with stateVersion 0', () async {
      _ok(await repo.createChallenge(localName: 'Yo'));

      final boxes = await db.select(db.ownBoxes).get();
      expect(boxes.length, 365);
      expect(boxes.every((b) => b.status == 0), isTrue);
      expect(boxes.map((b) => b.day).toSet(), {
        for (var d = 1; d <= 365; d++) d,
      });

      final config = await db.select(db.challengeConfigRows).getSingle();
      expect(config.stateVersion, 0);
      expect(config.localSlot, 0);
      expect(config.startEpochDay, clock.todayEpochDay());
    });

    test('returns a slot-A invite carrying the generated ids', () async {
      final invite = _ok(await repo.createChallenge(localName: 'Yo'));
      expect(invite.slot, 0);
      expect(invite.name, 'Yo');
      expect(invite.startEpochDay, clock.todayEpochDay());
    });
  });

  group('applyPairInvite branches (task 4.3)', () {
    PairInvite foreignInvite(int pairingId) => PairInvite(
      pairingId: pairingId,
      slot: 0,
      installId: 0xABCDEF,
      startEpochDay: clock.todayEpochDay(),
      name: 'Partner',
    );

    test('branch 1: no local pairing -> adopts and seeds the board', () async {
      final outcome = _ok(await repo.applyPairInvite(foreignInvite(0x1111)));
      expect(outcome, ApplyPairOutcome.adopted);

      final boxes = await db.select(db.ownBoxes).get();
      expect(boxes.length, 365);
      final config = await db.select(db.challengeConfigRows).getSingle();
      expect(config.pairingId, 0x1111);
      expect(config.localSlot, 1); // opposite of inviter's slot 0
      expect(config.partnerInstallId, 0xABCDEF);
    });

    test(
      'branch 2: same pairingId -> links partner, boxes untouched',
      () async {
        final mine = _ok(await repo.createChallenge(localName: 'Yo'));
        // Capture the board before applying.
        final before = await db.select(db.ownBoxes).get();

        final partner = PairInvite(
          pairingId: mine.pairingId,
          slot: 1,
          installId: 0x999,
          startEpochDay: mine.startEpochDay,
          name: 'Pareja',
        );
        final outcome = _ok(await repo.applyPairInvite(partner));
        expect(outcome, ApplyPairOutcome.partnerLinked);

        final config = await db.select(db.challengeConfigRows).getSingle();
        expect(config.partnerName, 'Pareja');
        expect(config.partnerInstallId, 0x999);

        final after = await db.select(db.ownBoxes).get();
        expect(after.length, before.length);
        expect(after.every((b) => b.status == 0), isTrue);
      },
    );

    test(
      'branch 3: different pairingId -> rejected, nothing written',
      () async {
        final mine = _ok(await repo.createChallenge(localName: 'Yo'));

        final outcome = _ok(
          await repo.applyPairInvite(foreignInvite(mine.pairingId ^ 0x1)),
        );
        expect(outcome, ApplyPairOutcome.rejectedForeign);

        final config = await db.select(db.challengeConfigRows).getSingle();
        // Partner still unset: the foreign invite left no trace.
        expect(config.partnerInstallId, isNull);
        expect(config.partnerName, isNull);
      },
    );
  });

  group('watchPairingState', () {
    test('starts Unpaired, becomes Paired after createChallenge', () async {
      final first = await repo.watchPairingState().first;
      expect(first, isA<Unpaired>());

      _ok(await repo.createChallenge(localName: 'Yo'));
      final next = await repo.watchPairingState().firstWhere(
        (s) => s is Paired,
      );
      expect((next as Paired).localName, 'Yo');
    });
  });

  group('resetChallenge', () {
    test('wipes every table back to unpaired', () async {
      _ok(await repo.createChallenge(localName: 'Yo'));
      _ok(await repo.resetChallenge());

      expect(await db.select(db.ownBoxes).get(), isEmpty);
      expect(await db.select(db.challengeConfigRows).get(), isEmpty);
      final state = _ok(await repo.readPairingState());
      expect(state, isA<Unpaired>());
    });
  });
}
