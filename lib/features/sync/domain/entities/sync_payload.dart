import 'box_state.dart';

/// A full-board SYNC payload (kind `0x01`).
///
/// Describes the sender's entire board. There are no deltas: every payload is
/// a complete replace. See `docs/qr-sync-protocol.md` §4.
final class SyncSnapshot {
  /// Creates a snapshot; [statuses] must hold exactly 365 entries.
  const SyncSnapshot({
    required this.pairingId,
    required this.slot,
    required this.installId,
    required this.stateVersion,
    required this.startEpochDay,
    required this.statuses,
  });

  /// uint32, fixed at pairing.
  final int pairingId;

  /// `0` = A, `1` = B (the sender).
  final int slot;

  /// uint64, random per install.
  final int installId;

  /// uint32, the sender's monotonic mutation counter.
  final int stateVersion;

  /// uint16, days since 1970-01-01 UTC.
  final int startEpochDay;

  /// Exactly 365 box states.
  final List<WireBoxState> statuses;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SyncSnapshot) return false;
    if (pairingId != other.pairingId ||
        slot != other.slot ||
        installId != other.installId ||
        stateVersion != other.stateVersion ||
        startEpochDay != other.startEpochDay ||
        statuses.length != other.statuses.length) {
      return false;
    }
    for (var i = 0; i < statuses.length; i++) {
      if (statuses[i] != other.statuses[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    pairingId,
    slot,
    installId,
    stateVersion,
    startEpochDay,
    Object.hashAll(statuses),
  );
}

/// A PAIR payload (kind `0x02`): the invitation and the response share this
/// shape, told apart by [slot]. See `docs/qr-sync-protocol.md` §5.1.
final class PairInvite {
  /// Creates a pairing invite/response.
  const PairInvite({
    required this.pairingId,
    required this.slot,
    required this.installId,
    required this.startEpochDay,
    required this.name,
  });

  /// uint32.
  final int pairingId;

  /// Sender's slot: `0` for the inviter, `1` for the responder.
  final int slot;

  /// uint64 of the sender.
  final int installId;

  /// uint16, days since 1970-01-01 UTC.
  final int startEpochDay;

  /// Sender's name, 1..24 UTF-8 bytes.
  final String name;

  @override
  bool operator ==(Object other) =>
      other is PairInvite &&
      pairingId == other.pairingId &&
      slot == other.slot &&
      installId == other.installId &&
      startEpochDay == other.startEpochDay &&
      name == other.name;

  @override
  int get hashCode =>
      Object.hash(pairingId, slot, installId, startEpochDay, name);
}

/// A RESTORE payload (kind `0x03`): returns a board to the person who lost it.
/// Variable length because of the sender's name. See
/// `docs/qr-sync-protocol.md` §5.2.
final class RestorePayload {
  /// Creates a restore payload; [statuses] must hold exactly 365 entries.
  const RestorePayload({
    required this.pairingId,
    required this.senderSlot,
    required this.senderInstallId,
    required this.restoredStateVersion,
    required this.startEpochDay,
    required this.snapshotEpochDay,
    required this.senderName,
    required this.statuses,
  });

  /// uint32.
  final int pairingId;

  /// Slot of the sender; the restored party takes the opposite.
  final int senderSlot;

  /// uint64 of the sender.
  final int senderInstallId;

  /// Last known stateVersion of the restored party.
  final int restoredStateVersion;

  /// uint16, the challenge start date.
  final int startEpochDay;

  /// uint16, the day the sender received this snapshot.
  final int snapshotEpochDay;

  /// Sender's name, 1..24 UTF-8 bytes.
  final String senderName;

  /// Exactly 365 box states — the restored party's board.
  final List<WireBoxState> statuses;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RestorePayload) return false;
    if (pairingId != other.pairingId ||
        senderSlot != other.senderSlot ||
        senderInstallId != other.senderInstallId ||
        restoredStateVersion != other.restoredStateVersion ||
        startEpochDay != other.startEpochDay ||
        snapshotEpochDay != other.snapshotEpochDay ||
        senderName != other.senderName ||
        statuses.length != other.statuses.length) {
      return false;
    }
    for (var i = 0; i < statuses.length; i++) {
      if (statuses[i] != other.statuses[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    pairingId,
    senderSlot,
    senderInstallId,
    restoredStateVersion,
    startEpochDay,
    snapshotEpochDay,
    senderName,
    Object.hashAll(statuses),
  );
}

/// Result of [decode]: exactly one of the three payload kinds, so consumers
/// must decide explicitly what to do with each.
sealed class DecodedPayload {
  const DecodedPayload();
}

/// A decoded SYNC payload.
final class DecodedSync extends DecodedPayload {
  /// Wraps the decoded [snapshot].
  const DecodedSync(this.snapshot);

  /// The decoded snapshot.
  final SyncSnapshot snapshot;
}

/// A decoded PAIR payload.
final class DecodedPair extends DecodedPayload {
  /// Wraps the decoded [invite].
  const DecodedPair(this.invite);

  /// The decoded invite/response.
  final PairInvite invite;
}

/// A decoded RESTORE payload.
final class DecodedRestore extends DecodedPayload {
  /// Wraps the decoded [payload].
  const DecodedRestore(this.payload);

  /// The decoded restore payload.
  final RestorePayload payload;
}
