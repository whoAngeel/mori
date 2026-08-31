import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';

/// Local persistence for the pairing feature. Talks to Drift directly and
/// throws [CacheException] on failure; the repository maps that to a [Failure].
///
/// Seeding writes to two tables — `ChallengeConfigRows` (pairing) and
/// `OwnBoxes` (challenge) — inside a single transaction. That cross-feature
/// write lives only here, in the Data layer, and is deliberate.
class PairingLocalDataSource {
  /// Creates the datasource over [_db].
  PairingLocalDataSource(this._db);

  final AppDatabase _db;

  static const _boxCount = 365;

  /// Reads the single config row, or null if no challenge exists.
  Future<ChallengeConfigRow?> readConfig() async {
    try {
      return await (_db.select(_db.challengeConfigRows)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
    } catch (e) {
      throw CacheException('readConfig failed: $e');
    }
  }

  /// Streams the single config row (or null).
  Stream<ChallengeConfigRow?> watchConfig() {
    return (_db.select(_db.challengeConfigRows)..where((t) => t.id.equals(1)))
        .watchSingleOrNull();
  }

  /// Seeds a brand-new challenge: writes the config row with
  /// `stateVersion = 0` and 365 free boxes, in one transaction.
  Future<void> seedChallenge({
    required int pairingId,
    required int localSlot,
    required int localInstallId,
    required String localName,
    required int startEpochDay,
    required int createdAtMillis,
    String? partnerName,
    int? partnerInstallId,
  }) async {
    try {
      await _db.transaction(() async {
        await _db.into(_db.challengeConfigRows).insert(
              ChallengeConfigRowsCompanion.insert(
                id: const Value(1),
                pairingId: pairingId,
                localSlot: localSlot,
                localInstallId: localInstallId,
                localName: localName,
                partnerName: Value(partnerName),
                partnerInstallId: Value(partnerInstallId),
                startEpochDay: startEpochDay,
                stateVersion: const Value(0),
                createdAtMillis: createdAtMillis,
              ),
            );
        await _db.batch((b) {
          b.insertAll(
            _db.ownBoxes,
            [
              for (var day = 1; day <= _boxCount; day++)
                OwnBoxesCompanion.insert(day: Value(day)),
            ],
          );
        });
      });
    } catch (e) {
      throw CacheException('seedChallenge failed: $e');
    }
  }

  /// Stores the partner's identity without touching the board.
  Future<void> linkPartner({
    required String partnerName,
    required int partnerInstallId,
  }) async {
    try {
      await (_db.update(_db.challengeConfigRows)..where((t) => t.id.equals(1)))
          .write(
        ChallengeConfigRowsCompanion(
          partnerName: Value(partnerName),
          partnerInstallId: Value(partnerInstallId),
        ),
      );
    } catch (e) {
      throw CacheException('linkPartner failed: $e');
    }
  }

  /// Updates either or both display names.
  Future<void> rename({String? localName, String? partnerName}) async {
    try {
      await (_db.update(_db.challengeConfigRows)..where((t) => t.id.equals(1)))
          .write(
        ChallengeConfigRowsCompanion(
          localName:
              localName == null ? const Value.absent() : Value(localName),
          partnerName:
              partnerName == null ? const Value.absent() : Value(partnerName),
        ),
      );
    } catch (e) {
      throw CacheException('rename failed: $e');
    }
  }

  /// Deletes every table, returning the app to the unpaired state.
  Future<void> wipe() async {
    try {
      await _db.transaction(() async {
        await _db.delete(_db.ownBoxes).go();
        await _db.delete(_db.partnerBoxes).go();
        await _db.delete(_db.partnerSnapshots).go();
        await _db.delete(_db.challengeConfigRows).go();
      });
    } catch (e) {
      throw CacheException('wipe failed: $e');
    }
  }
}
