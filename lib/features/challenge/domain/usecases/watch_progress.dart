import '../entities/box.dart';
import '../entities/challenge_progress.dart';

/// Derives a [ChallengeProgress] stream from a boxes stream, the clock and the
/// challenge start date.
///
/// Kept as a plain function of its inputs so it stays pure: the caller (a
/// provider) supplies the box stream and the two epoch-day values.
final class WatchProgress {
  /// Creates the use case.
  const WatchProgress();

  /// Maps [boxesStream] to progress, reading "today" from [todayEpochDay] each
  /// time boxes change.
  Stream<ChallengeProgress> call({
    required Stream<List<Box>> boxesStream,
    required int Function() todayEpochDay,
    required int startEpochDay,
  }) {
    return boxesStream.map(
      (boxes) => ChallengeProgress.from(
        boxes: boxes,
        todayEpochDay: todayEpochDay(),
        startEpochDay: startEpochDay,
      ),
    );
  }
}
