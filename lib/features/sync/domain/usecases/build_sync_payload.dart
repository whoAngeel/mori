import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/sync_repository.dart';

/// Builds this device's SYNC payload text for display as a QR.
final class BuildSyncPayload implements UseCase<String, NoParams> {
  /// Creates the use case over [_repository].
  const BuildSyncPayload(this._repository);

  final SyncRepository _repository;

  @override
  Future<Result<String>> call(NoParams params) =>
      _repository.buildSyncPayload();
}
