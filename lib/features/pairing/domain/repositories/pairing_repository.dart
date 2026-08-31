import '../../../../core/utils/result.dart';
import '../entities/pair_invite.dart';
import '../entities/pairing_state.dart';

/// The pairing feature's data contract. Implemented in the Data layer; used
/// only by the Domain use cases.
///
/// Methods that observe state return a [Stream]; commands return a
/// [Result]-wrapped [Future].
abstract interface class PairingRepository {
  /// Emits the current [PairingState] and every subsequent change.
  Stream<PairingState> watchPairingState();

  /// Reads the current pairing state once.
  Future<Result<PairingState>> readPairingState();

  /// Creates a fresh challenge on this device as slot A: seeds the 365 boxes
  /// and writes `stateVersion = 0`, all in one transaction.
  Future<Result<PairInvite>> createChallenge({required String localName});

  /// Joins an existing challenge as slot B from a scanned inviter payload,
  /// seeding the board and storing both identities in one transaction.
  Future<Result<PairInvite>> joinChallenge({
    required PairInvite inviterInvite,
    required String localName,
  });

  /// Builds this device's PAIR payload to show to the partner.
  Future<Result<PairInvite>> buildPairInvite();

  /// Applies a scanned partner PAIR payload. See [ApplyPairOutcome] for the
  /// three branches. Rejects a foreign pairing without writing.
  Future<Result<ApplyPairOutcome>> applyPairInvite(PairInvite partnerInvite);

  /// Renames the local participant and/or the partner.
  Future<Result<void>> renameParticipants({
    String? localName,
    String? partnerName,
  });

  /// Deletes the challenge and every board table, returning to unpaired.
  Future<Result<void>> resetChallenge();
}

/// Result of applying a partner PAIR payload.
enum ApplyPairOutcome {
  /// There was no local pairing: adopted the scanned challenge.
  adopted,

  /// Same `pairingId`: stored the partner's name and installId only, without
  /// touching any boxes.
  partnerLinked,

  /// Different `pairingId`: rejected, nothing written.
  rejectedForeign,
}
