import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/pair_invite.dart';
import '../repositories/pairing_repository.dart';

/// Applies a scanned partner PAIR payload.
///
/// Three branches, decided in the repository: adopt (no local pairing), link
/// (same `pairingId`, store name + installId only, boxes untouched), or reject
/// (different `pairingId`, nothing written).
final class ApplyPairPayload implements UseCase<ApplyPairOutcome, PairInvite> {
  /// Creates the use case over [_repository].
  const ApplyPairPayload(this._repository);

  final PairingRepository _repository;

  @override
  Future<Result<ApplyPairOutcome>> call(PairInvite partnerInvite) =>
      _repository.applyPairInvite(partnerInvite);
}
