import '../entities/box.dart';
import '../repositories/challenge_repository.dart';

/// Streams the 365 boxes for the board and home screens.
final class WatchBoxes {
  /// Creates the use case over [_repository].
  const WatchBoxes(this._repository);

  final ChallengeRepository _repository;

  /// Emits the boxes ordered by day, and every change.
  Stream<List<Box>> call() => _repository.watchBoxes();
}
