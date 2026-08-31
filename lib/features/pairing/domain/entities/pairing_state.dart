/// Where this device stands in the pairing ceremony.
///
/// Pure Dart. The router redirects on [isPaired]; the rest describes the
/// challenge identity once it exists.
sealed class PairingState {
  const PairingState();

  /// True once both participants are known and the board is seeded.
  bool get isPaired => this is Paired;
}

/// No challenge on this device yet: onboarding is the only destination.
final class Unpaired extends PairingState {
  /// Creates the unpaired state.
  const Unpaired();
}

/// A challenge exists on this device.
///
/// [partnerName] and [partnerInstallId] are null between creating a challenge
/// and the partner's response closing the pairing.
final class Paired extends PairingState {
  /// Creates a paired state from the stored challenge config.
  const Paired({
    required this.pairingId,
    required this.localSlot,
    required this.localInstallId,
    required this.localName,
    required this.startEpochDay,
    required this.stateVersion,
    this.partnerName,
    this.partnerInstallId,
  });

  /// Shared challenge id.
  final int pairingId;

  /// This device's slot: `0` = A, `1` = B.
  final int localSlot;

  /// This device's install id.
  final int localInstallId;

  /// This participant's display name.
  final String localName;

  /// Challenge start, days since 1970-01-01 UTC.
  final int startEpochDay;

  /// Monotonic local mutation counter.
  final int stateVersion;

  /// Partner's name, or null until pairing closes.
  final String? partnerName;

  /// Partner's install id, or null until pairing closes.
  final int? partnerInstallId;

  /// True once the partner's details are known.
  bool get isComplete => partnerInstallId != null;
}
