import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/pair_invite.dart';
import '../repositories/pairing_repository.dart';

/// Builds this device's PAIR invite for display as a QR.
final class BuildPairPayload implements UseCase<PairInvite, NoParams> {
  /// Creates the use case over [_repository].
  const BuildPairPayload(this._repository);

  final PairingRepository _repository;

  @override
  Future<Result<PairInvite>> call(NoParams params) =>
      _repository.buildPairInvite();
}
