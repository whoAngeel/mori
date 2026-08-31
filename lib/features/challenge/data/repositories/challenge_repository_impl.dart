import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/box.dart';
import '../../domain/entities/box_status.dart';
import '../../domain/entities/challenge_progress.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/challenge_local_data_source.dart';

/// Drift-backed [ChallengeRepository]. Maps rows to [Box] entities and
/// [CacheException]s to [Failure]s, and enforces the draw guards.
class ChallengeRepositoryImpl implements ChallengeRepository {
  /// Creates the repository over its datasource, database and clock.
  ChallengeRepositoryImpl(this._local, this._db, this._clock);

  final ChallengeLocalDataSource _local;
  final AppDatabase _db;
  final Clock _clock;

  static BoxStatus _statusOf(int raw) => switch (raw) {
    2 => BoxStatus.paid,
    1 => BoxStatus.assigned,
    _ => BoxStatus.free,
  };

  static Box _toBox(OwnBoxRow row) => Box(
    day: row.day,
    status: _statusOf(row.status),
    drawnAt: row.drawnAtMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row.drawnAtMillis!),
    paidAt: row.paidAtMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row.paidAtMillis!),
  );

  @override
  Stream<List<Box>> watchBoxes() =>
      _local.watchBoxes().map((rows) => rows.map(_toBox).toList());

  @override
  Future<Result<Box>> drawNextBox() async {
    try {
      // Guard: need a free box and a pending draw. Compute pending from the
      // current board and the challenge start date.
      final rows = await _db.select(_db.ownBoxes).get();
      final config = await (_db.select(
        _db.challengeConfigRows,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
      if (config == null) {
        return const Err(CacheFailure('No challenge configured'));
      }

      final boxes = rows.map(_toBox).toList();
      final progress = ChallengeProgress.from(
        boxes: boxes,
        todayEpochDay: _clock.todayEpochDay(),
        startEpochDay: config.startEpochDay,
      );

      if (progress.drawn >= ChallengeProgress.boxCount) {
        return const Err(NoBoxesLeft());
      }
      if (progress.pendingDraws == 0) {
        return const Err(NoDrawsPending());
      }

      final day = await _local.drawBox();
      if (day == null) return const Err(NoBoxesLeft());

      return Ok(
        Box(day: day, status: BoxStatus.assigned, drawnAt: _clock.now()),
      );
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> markPaid(int day) async {
    try {
      await _local.markPaid(day);
      return const Ok(null);
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }

  @override
  Future<Result<void>> unmarkPaid(int day) async {
    try {
      await _local.unmarkPaid(day);
      return const Ok(null);
    } on CacheException catch (e) {
      return Err(CacheFailure(e.message));
    }
  }
}
