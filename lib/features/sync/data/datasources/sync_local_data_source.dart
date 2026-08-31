import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/box_state.dart';

/// Local persistence for the sync feature.
///
/// Applying a snapshot is a single transaction that replaces all 365
/// `PartnerBoxes` rows and upserts `PartnerSnapshots` (§9, invariant I5). No
/// intermediate state is ever observable.
class SyncLocalDataSource {
  /// Creates the datasource over [_db].
  SyncLocalDataSource(this._db);

  final AppDatabase _db;

  static const _boxCount = 365;

  /// Reads the single config row, or null.
  Future<ChallengeConfigRow?> readConfig() => (_db.select(
    _db.challengeConfigRows,
  )..where((t) => t.id.equals(1))).getSingleOrNull();

  /// Reads the stored partner snapshot, or null.
  Future<PartnerSnapshotRow?> readPartnerSnapshot() => (_db.select(
    _db.partnerSnapshots,
  )..where((t) => t.id.equals(1))).getSingleOrNull();

  /// Reads this device's own board, ordered by day.
  Future<List<OwnBoxRow>> readOwnBoxes() => (_db.select(
    _db.ownBoxes,
  )..orderBy([(t) => OrderingTerm(expression: t.day)])).get();

  /// Reads the partner replica board, ordered by day.
  Future<List<PartnerBoxRow>> readPartnerBoxes() => (_db.select(
    _db.partnerBoxes,
  )..orderBy([(t) => OrderingTerm(expression: t.day)])).get();

  /// Streams the partner snapshot row (or null).
  Stream<PartnerSnapshotRow?> watchPartnerSnapshot() => (_db.select(
    _db.partnerSnapshots,
  )..where((t) => t.id.equals(1))).watchSingleOrNull();

  /// Streams the partner replica board.
  Stream<List<PartnerBoxRow>> watchPartnerBoxes() => (_db.select(
    _db.partnerBoxes,
  )..orderBy([(t) => OrderingTerm(expression: t.day)])).watch();

  /// Applies an accepted snapshot in one transaction: replaces all 365
  /// `PartnerBoxes` rows and upserts `PartnerSnapshots`.
  Future<void> applySnapshot({
    required List<WireBoxState> statuses,
    required int stateVersion,
    required int installId,
    required int startEpochDay,
    required int receivedAtMillis,
  }) async {
    assert(statuses.length == _boxCount, 'snapshot needs exactly 365 states');
    try {
      await _db.transaction(() async {
        await _db.delete(_db.partnerBoxes).go();
        await _db.batch((b) {
          b.insertAll(_db.partnerBoxes, [
            for (var day = 1; day <= _boxCount; day++)
              PartnerBoxesCompanion.insert(
                day: Value(day),
                status: Value(_wireValue(statuses[day - 1])),
              ),
          ]);
        });
        await _db
            .into(_db.partnerSnapshots)
            .insertOnConflictUpdate(
              PartnerSnapshotsCompanion.insert(
                id: const Value(1),
                stateVersion: stateVersion,
                installId: installId,
                startEpochDay: startEpochDay,
                receivedAtMillis: receivedAtMillis,
              ),
            );
      });
    } catch (e) {
      throw CacheException('applySnapshot failed: $e');
    }
  }

  /// Seeds a fresh challenge from a RESTORE, in one transaction: writes the
  /// config and 365 own boxes with null dates. Does not touch partner tables.
  Future<void> seedFromRestore({
    required int pairingId,
    required int localSlot,
    required int localInstallId,
    required String localName,
    required String partnerName,
    required int partnerInstallId,
    required int startEpochDay,
    required int stateVersion,
    required int createdAtMillis,
    required List<WireBoxState> statuses,
  }) async {
    assert(statuses.length == _boxCount, 'restore needs exactly 365 states');
    try {
      await _db.transaction(() async {
        await _db
            .into(_db.challengeConfigRows)
            .insert(
              ChallengeConfigRowsCompanion.insert(
                id: const Value(1),
                pairingId: pairingId,
                localSlot: localSlot,
                localInstallId: localInstallId,
                localName: localName,
                partnerName: Value(partnerName),
                partnerInstallId: Value(partnerInstallId),
                startEpochDay: startEpochDay,
                stateVersion: Value(stateVersion),
                createdAtMillis: createdAtMillis,
              ),
            );
        await _db.batch((b) {
          b.insertAll(_db.ownBoxes, [
            for (var day = 1; day <= _boxCount; day++)
              OwnBoxesCompanion.insert(
                day: Value(day),
                status: Value(_wireValue(statuses[day - 1])),
              ),
          ]);
        });
      });
    } catch (e) {
      throw CacheException('seedFromRestore failed: $e');
    }
  }

  static int _wireValue(WireBoxState s) => switch (s) {
    WireBoxState.free => 0,
    WireBoxState.assigned => 1,
    WireBoxState.paid => 2,
  };
}
