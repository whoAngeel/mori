import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/random/random_providers.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/pairing_local_data_source.dart';
import '../../data/repositories/pairing_repository_impl.dart';
import '../../domain/entities/pair_invite.dart';
import '../../domain/entities/pairing_state.dart';
import '../../domain/repositories/pairing_repository.dart';
import '../../domain/usecases/apply_pair_payload.dart';
import '../../domain/usecases/create_challenge.dart';
import '../../domain/usecases/join_challenge.dart';
import '../../domain/usecases/reset_challenge.dart';
import '../../domain/usecases/watch_pairing_state.dart';

part 'pairing_notifier.g.dart';

// --- Dependency injection (lives in Presentation to keep Domain pure) ---

/// The pairing datasource.
@riverpod
PairingLocalDataSource pairingLocalDataSource(Ref ref) =>
    PairingLocalDataSource(ref.watch(appDatabaseProvider));

/// The pairing repository, wired with the clock and RNG.
@riverpod
PairingRepository pairingRepository(Ref ref) => PairingRepositoryImpl(
  ref.watch(pairingLocalDataSourceProvider),
  ref.watch(clockProvider),
  ref.watch(randomProvider),
);

/// Streams the pairing state for the router redirect and UI.
@riverpod
Stream<PairingState> pairingState(Ref ref) =>
    WatchPairingState(ref.watch(pairingRepositoryProvider)).call();

// --- Commands ---

/// Coordinates the pairing ceremony commands.
@riverpod
class PairingController extends _$PairingController {
  @override
  void build() {}

  PairingRepository get _repo => ref.read(pairingRepositoryProvider);

  /// Creates a fresh challenge as slot A and returns the invite to show.
  Future<Result<PairInvite>> createChallenge(String localName) =>
      CreateChallenge(_repo).call(localName);

  /// Joins an existing challenge as slot B from a scanned inviter payload.
  Future<Result<PairInvite>> joinChallenge({
    required PairInvite inviterInvite,
    required String localName,
  }) => JoinChallenge(_repo).call(
    JoinChallengeParams(inviterInvite: inviterInvite, localName: localName),
  );

  /// Applies a scanned partner PAIR payload.
  Future<Result<ApplyPairOutcome>> applyPartner(PairInvite invite) =>
      ApplyPairPayload(_repo).call(invite);

  /// Resets the challenge and returns to onboarding.
  Future<Result<void>> reset() => ResetChallenge(_repo).call(const NoParams());
}
