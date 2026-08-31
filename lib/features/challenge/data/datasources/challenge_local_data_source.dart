import 'dart:math';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';

/// Local persistence for the challenge feature.
///
/// Every mutation runs inside a single transaction that also bumps
/// `stateVersion` in `ChallengeConfigRows` (invariant I4). That table belongs
/// to the `pairing` feature; writing it here is the deliberate cross-feature
/// coupling documented in `docs/data-model.md` §2.1.
class ChallengeLocalDataSource {
  /// Creates the datasource over [_db], seeded [_random] and current time from
  /// [_nowMillis].
  ChallengeLocalDataSource(this._db, this._random, this._nowMillis);

  final AppDatabase _db;
  final Random _random;
  final int Function() _nowMillis;

  /// A box at or above this amount (in MXN) counts as "expensive". Two of them
  /// never come out back to back — see [drawBox].
  static const highThreshold = 300;

  /// Streams the 365 boxes ordered by day.
  Stream<List<OwnBoxRow>> watchBoxes() {
    return (_db.select(
      _db.ownBoxes,
    )..orderBy([(t) => OrderingTerm(expression: t.day)])).watch();
  }

  /// Bumps `stateVersion` by one. Must run inside an open transaction.
  Future<void> _bumpVersion() async {
    await _db.customStatement(
      'UPDATE challenge_config_rows SET state_version = state_version + 1 '
      'WHERE id = 1',
    );
  }

  /// Draws one random free box. Returns the chosen day, or null if none are
  /// free. Selection and write happen in one transaction, so two fast taps can
  /// never assign the same box twice.
  ///
  /// Anti-streak (design decision, cash-flow): two boxes `>= [highThreshold]`
  /// never come out on consecutive draws. If the previous draw was expensive,
  /// this one is restricted to the cheaper free boxes — unless every free box
  /// left is expensive, in which case the rule relaxes so the pool still
  /// drains completely. Reordering only: the full 365 and the total are
  /// unchanged, and it never crosses the QR (still just box states).
  ///
  /// Throws [CacheException] on a database error.
  Future<int?> drawBox() async {
    try {
      return await _db.transaction<int?>(() async {
        final free = await (_db.select(
          _db.ownBoxes,
        )..where((t) => t.status.equals(0))).get();
        if (free.isEmpty) return null;

        // The most recently drawn box, by draw time.
        final last =
            await (_db.select(_db.ownBoxes)
                  ..where((t) => t.drawnAtMillis.isNotNull())
                  ..orderBy([
                    (t) => OrderingTerm(
                      expression: t.drawnAtMillis,
                      mode: OrderingMode.desc,
                    ),
                  ])
                  ..limit(1))
                .getSingleOrNull();

        var pool = free;
        if (last != null && last.day >= highThreshold) {
          final cheap = free.where((b) => b.day < highThreshold).toList();
          if (cheap.isNotEmpty) pool = cheap;
        }

        final chosen = pool[_random.nextInt(pool.length)];
        await (_db.update(
          _db.ownBoxes,
        )..where((t) => t.day.equals(chosen.day))).write(
          OwnBoxesCompanion(
            status: const Value(1),
            drawnAtMillis: Value(_nowMillis()),
          ),
        );
        await _bumpVersion();
        return chosen.day;
      });
    } catch (e) {
      throw CacheException('drawBox failed: $e');
    }
  }

  /// Marks a drawn box paid, bumping the version in the same transaction.
  Future<void> markPaid(int day) async {
    try {
      await _db.transaction(() async {
        await (_db.update(_db.ownBoxes)..where((t) => t.day.equals(day))).write(
          OwnBoxesCompanion(
            status: const Value(2),
            paidAtMillis: Value(_nowMillis()),
          ),
        );
        await _bumpVersion();
      });
    } catch (e) {
      throw CacheException('markPaid failed: $e');
    }
  }

  /// Reverts a paid box back to assigned (I3), clearing the paid time.
  Future<void> unmarkPaid(int day) async {
    try {
      await _db.transaction(() async {
        await (_db.update(_db.ownBoxes)..where((t) => t.day.equals(day))).write(
          const OwnBoxesCompanion(status: Value(1), paidAtMillis: Value(null)),
        );
        await _bumpVersion();
      });
    } catch (e) {
      throw CacheException('unmarkPaid failed: $e');
    }
  }
}
