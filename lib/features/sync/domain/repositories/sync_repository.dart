import '../../../../core/utils/result.dart';
import '../entities/partner_snapshot.dart';
import '../entities/sync_outcome.dart';

/// The sync feature's data contract. Implemented in Data, used by the Domain
/// use cases.
///
/// The codec (checks 1..7) runs first; the repository owns checks 8..10 and the
/// acceptance rule (§8), because those need local state.
abstract interface class SyncRepository {
  /// Builds this device's SYNC payload text (base64url), or a failure.
  Future<Result<String>> buildSyncPayload();

  /// Decodes and applies a scanned SYNC payload, returning the outcome.
  Future<Result<SyncOutcome>> applySyncPayload(String scannedText);

  /// Builds a RESTORE payload for the partner from the stored replica.
  ///
  /// Read-only: never bumps stateVersion. Fails with `NothingToRestore` when
  /// there is no partner snapshot to emit.
  Future<Result<String>> buildRestorePayload();

  /// Decodes and applies a scanned RESTORE payload, seeding a fresh board.
  ///
  /// Guard: rejects with `RestoreNotApplicable` when a challenge already
  /// exists (§8.3). [localName] is the name the recovering person typed.
  Future<Result<SyncOutcome>> applyRestorePayload({
    required String scannedText,
    required String localName,
  });

  /// Emits the partner's last snapshot description (or null), and changes.
  Stream<PartnerSnapshot?> watchPartnerSnapshot();

  /// Emits the partner's replica board (0 or 365 boxes), and changes.
  Stream<List<PartnerBox>> watchPartnerBoxes();
}
