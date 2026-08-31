import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/pairing_repository.dart';

/// Deletes the challenge and every board table, returning to unpaired.
final class ResetChallenge implements UseCase<void, NoParams> {
  /// Creates the use case over [_repository].
  const ResetChallenge(this._repository);

  final PairingRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.resetChallenge();
}
