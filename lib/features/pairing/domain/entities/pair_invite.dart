/// A pairing invitation or response, as understood by the `pairing` domain.
///
/// This is the domain view of a PAIR payload. The `sync` codec has its own
/// wire-level `PairInvite`; the two never import each other. The repository is
/// responsible for translating between them.
final class PairInvite {
  /// Creates a pairing invite/response.
  const PairInvite({
    required this.pairingId,
    required this.slot,
    required this.installId,
    required this.startEpochDay,
    required this.name,
  });

  /// Shared challenge id.
  final int pairingId;

  /// Sender's slot: `0` = inviter (A), `1` = responder (B).
  final int slot;

  /// Sender's install id.
  final int installId;

  /// Challenge start, days since 1970-01-01 UTC.
  final int startEpochDay;

  /// Sender's display name, 1..24 UTF-8 bytes.
  final String name;
}
