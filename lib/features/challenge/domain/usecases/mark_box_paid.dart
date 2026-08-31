import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/challenge_repository.dart';

/// Marks a drawn box as paid.
final class MarkBoxPaid implements UseCase<void, int> {
  /// Creates the use case over [_repository].
  const MarkBoxPaid(this._repository);

  final ChallengeRepository _repository;

  @override
  Future<Result<void>> call(int day) => _repository.markPaid(day);
}
