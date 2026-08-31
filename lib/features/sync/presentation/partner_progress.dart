import '../domain/entities/box_state.dart';
import '../domain/entities/partner_snapshot.dart';

/// Progress of the partner's board, computed from their replica.
///
/// Deliberately computed in the sync feature (not by reusing challenge's
/// `ChallengeProgress`) so the Domain layers stay isolated. The math mirrors
/// `docs/data-model.md` §4, and the challenge day uses the partner's own
/// [PartnerSnapshot.startEpochDay], never the local one.
final class PartnerProgress {
  /// Creates a partner progress snapshot.
  const PartnerProgress({
    required this.savedMxn,
    required this.committedMxn,
    required this.drawn,
    required this.paid,
    required this.challengeDay,
  });

  /// Sum of paid amounts.
  final int savedMxn;

  /// Sum of drawn amounts (paid or not).
  final int committedMxn;

  /// Number of drawn boxes.
  final int drawn;

  /// Number of paid boxes.
  final int paid;

  /// 1-based day of the partner's challenge, from their own start date.
  final int challengeDay;

  /// Computes progress from the partner's [boxes] and their [snapshot].
  factory PartnerProgress.from({
    required List<PartnerBox> boxes,
    required PartnerSnapshot snapshot,
    required int todayEpochDay,
  }) {
    var saved = 0;
    var committed = 0;
    var drawn = 0;
    var paid = 0;
    for (final b in boxes) {
      if (b.status != WireBoxState.free) {
        drawn++;
        committed += b.day;
      }
      if (b.status == WireBoxState.paid) {
        paid++;
        saved += b.day;
      }
    }
    final elapsed = todayEpochDay - snapshot.startEpochDay;
    final challengeDay = (elapsed + 1).clamp(1, 365);
    return PartnerProgress(
      savedMxn: saved,
      committedMxn: committed,
      drawn: drawn,
      paid: paid,
      challengeDay: challengeDay,
    );
  }
}
