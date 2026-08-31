import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/database/app_database.dart';
import 'package:mori/core/error/failures.dart';
import 'package:mori/core/utils/result.dart';
import 'package:mori/features/challenge/data/datasources/challenge_local_data_source.dart';
import 'package:mori/features/challenge/data/repositories/challenge_repository_impl.dart';
import 'package:mori/features/challenge/domain/entities/box.dart';
import 'package:mori/features/challenge/domain/entities/box_status.dart';
import 'package:mori/features/pairing/data/datasources/pairing_local_data_source.dart';

import '../../../helpers/fake_clock.dart';

Failure _err<T>(Result<T> r) => switch (r) {
  Err<T>(:final failure) => failure,
  Ok<T>() => fail('expected Err, got Ok'),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ChallengeRepositoryImpl repo;
  late FakeClock clock;
  const startEpochDay = 20000;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await PairingLocalDataSource(db).seedChallenge(
      pairingId: 1,
      localSlot: 0,
      localInstallId: 1,
      localName: 'Yo',
      startEpochDay: startEpochDay,
      createdAtMillis: 0,
    );
    // Far in the future so pending draws never run out during the test.
    clock = FakeClock(DateTime(1970).add(Duration(days: startEpochDay + 1000)));
    final ds = ChallengeLocalDataSource(
      db,
      Random(7),
      () => clock.now().millisecondsSinceEpoch,
    );
    repo = ChallengeRepositoryImpl(ds, db, clock);
  });

  tearDown(() => db.close());

  group('draw guards (task 5.5)', () {
    test('365 draws consume exactly the 365 boxes without repeating', () async {
      final drawnDays = <int>{};
      for (var i = 0; i < 365; i++) {
        final result = await repo.drawNextBox();
        final box = switch (result) {
          Ok(:final value) => value,
          Err(:final failure) => fail('draw ${i + 1} failed: $failure'),
        };
        expect(
          drawnDays.add(box.day),
          isTrue,
          reason: 'day ${box.day} drawn twice',
        );
      }
      expect(drawnDays.length, 365);
      expect(drawnDays, {for (var d = 1; d <= 365; d++) d});
    });

    test('the 366th draw fails with NoBoxesLeft', () async {
      for (var i = 0; i < 365; i++) {
        await repo.drawNextBox();
      }
      expect(_err(await repo.drawNextBox()), isA<NoBoxesLeft>());
    });

    test('with no pending draws, fails with NoDrawsPending', () async {
      // First day only: exactly one pending draw.
      clock.setNow(DateTime(1970).add(const Duration(days: startEpochDay)));
      final first = await repo.drawNextBox();
      expect(first, isA<Ok<Box>>());
      // Second draw the same day: pending is now 0.
      expect(_err(await repo.drawNextBox()), isA<NoDrawsPending>());
    });

    test('an assigned box never returns to free', () async {
      final assignedDays = <int>{};
      for (var i = 0; i < 50; i++) {
        final box = switch (await repo.drawNextBox()) {
          Ok(:final value) => value,
          Err(:final failure) => fail('draw failed: $failure'),
        };
        assignedDays.add(box.day);
      }
      final boxes = await repo.watchBoxes().first;
      for (final b in boxes) {
        if (assignedDays.contains(b.day)) {
          expect(
            b.status,
            isNot(BoxStatus.free),
            reason: 'day ${b.day} reverted to free',
          );
        }
      }
    });
  });

  group('pay / unpay', () {
    test('markPaid then unmarkPaid round-trips status', () async {
      final box = switch (await repo.drawNextBox()) {
        Ok(:final value) => value,
        Err() => fail('draw failed'),
      };
      expect(await repo.markPaid(box.day), isA<Ok<void>>());
      var boxes = await repo.watchBoxes().first;
      expect(boxes.firstWhere((b) => b.day == box.day).status, BoxStatus.paid);

      expect(await repo.unmarkPaid(box.day), isA<Ok<void>>());
      boxes = await repo.watchBoxes().first;
      expect(
        boxes.firstWhere((b) => b.day == box.day).status,
        BoxStatus.assigned,
      );
    });
  });
}
