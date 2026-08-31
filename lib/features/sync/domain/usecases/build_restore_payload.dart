import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/sync_repository.dart';

/// Builds a RESTORE payload for the partner from the stored replica.
///
/// Read-only: never bumps stateVersion. Fails with `NothingToRestore` when
/// there is no partner snapshot.
final class BuildRestorePayload implements UseCase<String, NoParams> {
  /// Creates the use case over [_repository].
  const BuildRestorePayload(this._repository);

  final SyncRepository _repository;

  @override
  Future<Result<String>> call(NoParams params) =>
      _repository.buildRestorePayload();
}
