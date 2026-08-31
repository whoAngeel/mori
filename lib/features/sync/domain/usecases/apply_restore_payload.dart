import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/sync_outcome.dart';
import '../repositories/sync_repository.dart';

/// Input for [ApplyRestorePayload]: the scanned text and the recovering
/// person's own name (which does not travel in the payload).
final class ApplyRestoreParams {
  /// Bundles the scanned text with the local name.
  const ApplyRestoreParams({
    required this.scannedText,
    required this.localName,
  });

  /// The scanned RESTORE payload text.
  final String scannedText;

  /// The name the recovering person typed.
  final String localName;
}

/// Applies a scanned RESTORE payload, seeding a fresh board.
///
/// The hard guard (reject when a challenge already exists, §8.3) lives in the
/// repository, not here.
final class ApplyRestorePayload
    implements UseCase<SyncOutcome, ApplyRestoreParams> {
  /// Creates the use case over [_repository].
  const ApplyRestorePayload(this._repository);

  final SyncRepository _repository;

  @override
  Future<Result<SyncOutcome>> call(ApplyRestoreParams params) =>
      _repository.applyRestorePayload(
        scannedText: params.scannedText,
        localName: params.localName,
      );
}
