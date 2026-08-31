import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/challenge_repository.dart';

/// Reverts a paid box back to assigned (the only backwards transition, I3).
final class UnmarkBoxPaid implements UseCase<void, int> {
  /// Creates the use case over [_repository].
  const UnmarkBoxPaid(this._repository);

  final ChallengeRepository _repository;

  @override
  Future<Result<void>> call(int day) => _repository.unmarkPaid(day);
}
