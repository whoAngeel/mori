import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/pair_invite.dart';
import '../repositories/pairing_repository.dart';

/// Starts a fresh challenge on this device as slot A.
///
/// Seeds the 365 boxes and sets `stateVersion = 0` in one transaction, then
/// returns the PAIR invite to show to the partner.
final class CreateChallenge implements UseCase<PairInvite, String> {
  /// Creates the use case over [_repository].
  const CreateChallenge(this._repository);

  final PairingRepository _repository;

  @override
  Future<Result<PairInvite>> call(String localName) =>
      _repository.createChallenge(localName: localName);
}
