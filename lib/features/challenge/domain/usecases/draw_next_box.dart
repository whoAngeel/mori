import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/box.dart';
import '../repositories/challenge_repository.dart';

/// Draws the next random box. Fails with `NoBoxesLeft` or `NoDrawsPending`.
final class DrawNextBox implements UseCase<Box, NoParams> {
  /// Creates the use case over [_repository].
  const DrawNextBox(this._repository);

  final ChallengeRepository _repository;

  @override
  Future<Result<Box>> call(NoParams params) => _repository.drawNextBox();
}
