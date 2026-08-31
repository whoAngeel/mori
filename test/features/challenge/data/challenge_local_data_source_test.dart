import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/database/app_database.dart';
import 'package:mori/features/challenge/data/datasources/challenge_local_data_source.dart';
import 'package:mori/features/pairing/data/datasources/pairing_local_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ChallengeLocalDataSource ds;
  var fakeMillis = 1000;

  Future<int> stateVersion() async {
    final row = await db.select(db.challengeConfigRows).getSingle();
    return row.stateVersion;
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Seed a challenge (config + 365 boxes) via the pairing datasource.
    await PairingLocalDataSource(db).seedChallenge(
      pairingId: 1,
      localSlot: 0,
      localInstallId: 1,
      localName: 'Yo',
      startEpochDay: 20000,
      createdAtMillis: 0,
    );
    ds = ChallengeLocalDataSource(db, Random(7), () => fakeMillis);
  });

  tearDown(() => db.close());

  group('drawBox atomicity (task 5.3)', () {
    test('a draw bumps stateVersion in the same transaction', () async {
      expect(await stateVersion(), 0);
      final day = await ds.drawBox();
      expect(day, isNotNull);
      expect(await stateVersion(), 1);

      final row = await (db.select(
        db.ownBoxes,
      )..where((t) => t.day.equals(day!))).getSingle();
      expect(row.status, 1); // assigned
      expect(row.drawnAtMillis, fakeMillis);
    });

    test('each mutation increments stateVersion by exactly one', () async {
      final d1 = (await ds.drawBox())!;
      expect(await stateVersion(), 1);
      await ds.markPaid(d1);
      expect(await stateVersion(), 2);
      await ds.unmarkPaid(d1);
      expect(await stateVersion(), 3);
    });

    test('markPaid sets status 2 and stamps paidAtMillis', () async {
      final day = (await ds.drawBox())!;
      fakeMillis = 5000;
      await ds.markPaid(day);
      final row = await (db.select(
        db.ownBoxes,
      )..where((t) => t.day.equals(day))).getSingle();
      expect(row.status, 2);
      expect(row.paidAtMillis, 5000);
    });

    test(
      'unmarkPaid reverts to assigned and clears paidAtMillis (I3)',
      () async {
        final day = (await ds.drawBox())!;
        await ds.markPaid(day);
        await ds.unmarkPaid(day);
        final row = await (db.select(
          db.ownBoxes,
        )..where((t) => t.day.equals(day))).getSingle();
        expect(row.status, 1); // assigned
        expect(row.paidAtMillis, isNull);
      },
    );

    test('drawBox returns null when no free boxes remain', () async {
      // Draw all 365.
      for (var i = 0; i < 365; i++) {
        final day = await ds.drawBox();
        expect(day, isNotNull);
      }
      expect(await ds.drawBox(), isNull);
      expect(await stateVersion(), 365); // no bump on the empty draw
    });
  });

  group('anti-streak: no two expensive draws in a row', () {
    const t = ChallengeLocalDataSource.highThreshold; // 300

    /// Draws the whole pool, one draw per millisecond so "last drawn" is
    /// unambiguous, and returns the days in draw order.
    Future<List<int>> drawAllInOrder() async {
      final order = <int>[];
      for (var i = 0; i < 365; i++) {
        fakeMillis += 1;
        final day = await ds.drawBox();
        expect(day, isNotNull);
        order.add(day!);
      }
      return order;
    }

    test('never two boxes >= 300 back to back while cheap boxes remain',
        () async {
      final order = await drawAllInOrder();
      expect(order.toSet().length, 365); // still every box, no repeat

      var cheapDrawn = 0;
      const cheapTotal = t - 1; // days 1..299
      for (var i = 0; i < order.length; i++) {
        if (i > 0 && order[i] >= t && order[i - 1] >= t) {
          final cheapRemaining = cheapTotal - cheapDrawn;
          expect(
            cheapRemaining,
            0,
            reason: 'drew ${order[i - 1]} then ${order[i]} with '
                '$cheapRemaining cheap boxes still free',
          );
        }
        if (order[i] < t) cheapDrawn++;
      }
    });

    test('relaxes at the end: the pool still drains to exactly 365', () async {
      final order = await drawAllInOrder();
      expect(order.length, 365);
      expect(order.toSet().length, 365);
      expect(await ds.drawBox(), isNull);
    });
  });
}
