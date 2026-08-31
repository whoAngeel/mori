/// The result of applying a scanned payload to the local database.
///
/// Sealed so the UI must handle every branch and map each to its exact copy
/// string (`docs/design-system.md` §8).
sealed class SyncOutcome {
  const SyncOutcome();
}

/// The snapshot was newer and got written.
final class SyncApplied extends SyncOutcome {
  /// Wraps the newly stored [stateVersion].
  const SyncApplied(this.stateVersion);

  /// The stateVersion now stored.
  final int stateVersion;
}

/// The same snapshot was scanned again: nothing changed. "Ya estabas al día".
final class SyncNoChange extends SyncOutcome {
  /// Creates the no-change outcome.
  const SyncNoChange();
}

/// The partner reinstalled (different installId): the baseline was reset.
///
/// [lostProgress] distinguishes a real loss from a post-restore reinstall, so
/// the UI can pick the honest message (§8.1).
final class SyncPartnerReset extends SyncOutcome {
  /// Creates the reset outcome.
  const SyncPartnerReset({required this.lostProgress});

  /// True when the incoming board has fewer non-free boxes than the stored one.
  final bool lostProgress;
}

/// A RESTORE was applied: the local board was recreated.
final class RestoreApplied extends SyncOutcome {
  /// Wraps how stale the recovered snapshot is, in days.
  const RestoreApplied(this.daysStale);

  /// Days between the challenge "today" and the snapshot's date.
  final int daysStale;
}
