import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/sync_outcome.dart';
import '../repositories/sync_repository.dart';

/// Applies a scanned SYNC payload, returning the [SyncOutcome].
final class ApplySyncPayload implements UseCase<SyncOutcome, String> {
  /// Creates the use case over [_repository].
  const ApplySyncPayload(this._repository);

  final SyncRepository _repository;

  @override
  Future<Result<SyncOutcome>> call(String scannedText) =>
      _repository.applySyncPayload(scannedText);
}
