import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/pair_invite.dart';
import '../repositories/pairing_repository.dart';

/// Input for [JoinChallenge]: the scanned inviter payload plus this device's
/// chosen name.
final class JoinChallengeParams {
  /// Bundles the inviter's payload with the local name.
  const JoinChallengeParams({
    required this.inviterInvite,
    required this.localName,
  });

  /// The PAIR payload scanned from the inviter (slot A).
  final PairInvite inviterInvite;

  /// This device's display name.
  final String localName;
}

/// Joins an existing challenge as slot B, seeding the local board.
final class JoinChallenge implements UseCase<PairInvite, JoinChallengeParams> {
  /// Creates the use case over [_repository].
  const JoinChallenge(this._repository);

  final PairingRepository _repository;

  @override
  Future<Result<PairInvite>> call(JoinChallengeParams params) =>
      _repository.joinChallenge(
        inviterInvite: params.inviterInvite,
        localName: params.localName,
      );
}
