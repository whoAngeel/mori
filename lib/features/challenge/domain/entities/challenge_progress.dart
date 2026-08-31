import 'box.dart';
import 'box_status.dart';

/// A snapshot of board progress, derived from the boxes and the clock.
///
/// All arithmetic from `docs/data-model.md` §4 lives here, in pure Dart. No
/// Flutter, no Drift. This is the most edge-prone part of the app and the one
/// that most deserves tests.
final class ChallengeProgress {
  /// Creates a progress snapshot. Prefer [ChallengeProgress.from].
  const ChallengeProgress({
    required this.savedMxn,
    required this.committedMxn,
    required this.owedMxn,
    required this.remainingMxn,
    required this.drawn,
    required this.paid,
    required this.pendingDraws,
    required this.challengeDay,
  });

  /// Sum of all 365 amounts: `sum(1..365)`.
  static const totalMxn = 66795;

  /// Total boxes on a board.
  static const boxCount = 365;

  /// Paid so far, in MXN.
  final int savedMxn;

  /// Drawn (paid or not), in MXN.
  final int committedMxn;

  /// Drawn but not yet paid, in MXN.
  final int owedMxn;

  /// Not drawn yet, in MXN.
  final int remainingMxn;

  /// Number of drawn boxes (assigned or paid).
  final int drawn;

  /// Number of paid boxes.
  final int paid;

  /// Draws available to spend today (accumulated).
  final int pendingDraws;

  /// 1-based day of the challenge (`elapsed + 1`), clamped to `[1, 365]` for
  /// display. A backwards clock floors it at 1.
  final int challengeDay;

  /// True once every box has been drawn: the draw button is disabled forever.
  bool get isComplete => drawn >= boxCount;

  /// Computes progress from [boxes] and the two epoch-day values.
  ///
  /// [todayEpochDay] and [startEpochDay] are civil-day counts (see
  /// `core/time/clock.dart`).
  factory ChallengeProgress.from({
    required List<Box> boxes,
    required int todayEpochDay,
    required int startEpochDay,
  }) {
    final drawn = boxes.where((b) => b.status != BoxStatus.free).length;
    final paid = boxes.where((b) => b.status == BoxStatus.paid).length;

    final savedMxn = boxes
        .where((b) => b.status == BoxStatus.paid)
        .fold(0, (s, b) => s + b.day);
    final committedMxn = boxes
        .where((b) => b.status != BoxStatus.free)
        .fold(0, (s, b) => s + b.day);

    final owedMxn = committedMxn - savedMxn;
    final remainingMxn = totalMxn - committedMxn;

    // Pending draws: one per calendar day, unplayed days accumulate (D3).
    final elapsed = todayEpochDay - startEpochDay; // 0 on the first day
    final earned = (elapsed + 1).clamp(0, boxCount); // draws earned so far
    // The upper clamp to (boxCount - drawn) stops someone who let months pass
    // from emptying the board beyond what exists.
    final pending = (earned - drawn).clamp(0, boxCount - drawn);

    final challengeDay = (elapsed + 1).clamp(1, boxCount);

    return ChallengeProgress(
      savedMxn: savedMxn,
      committedMxn: committedMxn,
      owedMxn: owedMxn,
      remainingMxn: remainingMxn,
      drawn: drawn,
      paid: paid,
      pendingDraws: pending,
      challengeDay: challengeDay,
    );
  }
}
