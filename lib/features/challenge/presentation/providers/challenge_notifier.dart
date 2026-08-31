import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/random/random_providers.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../pairing/domain/entities/pairing_state.dart';
import '../../../pairing/presentation/providers/pairing_notifier.dart';
import '../../data/datasources/challenge_local_data_source.dart';
import '../../data/repositories/challenge_repository_impl.dart';
import '../../domain/entities/box.dart';
import '../../domain/entities/challenge_progress.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../../domain/usecases/draw_next_box.dart';
import '../../domain/usecases/mark_box_paid.dart';
import '../../domain/usecases/unmark_box_paid.dart';

part 'challenge_notifier.g.dart';

// --- Dependency injection (Presentation keeps Domain pure) ---

/// The challenge datasource, wired with the RNG and the clock's millis.
@riverpod
ChallengeLocalDataSource challengeLocalDataSource(Ref ref) {
  final clock = ref.watch(clockProvider);
  return ChallengeLocalDataSource(
    ref.watch(appDatabaseProvider),
    ref.watch(randomProvider),
    () => clock.now().millisecondsSinceEpoch,
  );
}

/// The challenge repository.
@riverpod
ChallengeRepository challengeRepository(Ref ref) => ChallengeRepositoryImpl(
      ref.watch(challengeLocalDataSourceProvider),
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    );

/// The immutable state the home and board screens render.
final class ChallengeState {
  /// Creates a challenge state.
  const ChallengeState({required this.boxes, required this.progress});

  /// The 365 boxes, ordered by day.
  final List<Box> boxes;

  /// Derived progress.
  final ChallengeProgress progress;
}

/// Streams boxes + progress and exposes the board commands.
@riverpod
class ChallengeNotifier extends _$ChallengeNotifier {
  @override
  Stream<ChallengeState> build() async* {
    final repo = ref.watch(challengeRepositoryProvider);
    final clock = ref.watch(clockProvider);
    final pairing = await ref.watch(pairingStateProvider.future);
    final startEpochDay = switch (pairing) {
      Paired(:final startEpochDay) => startEpochDay,
      _ => clock.todayEpochDay(),
    };

    yield* repo.watchBoxes().map(
          (boxes) => ChallengeState(
            boxes: boxes,
            progress: ChallengeProgress.from(
              boxes: boxes,
              todayEpochDay: clock.todayEpochDay(),
              startEpochDay: startEpochDay,
            ),
          ),
        );
  }

  ChallengeRepository get _repo => ref.read(challengeRepositoryProvider);

  /// Draws the next box. Returns the result so the UI can show a message.
  Future<Result<Box>> draw() => DrawNextBox(_repo).call(const NoParams());

  /// Marks a box paid.
  Future<Result<void>> markPaid(int day) => MarkBoxPaid(_repo).call(day);

  /// Reverts a paid box.
  Future<Result<void>> unmarkPaid(int day) => UnmarkBoxPaid(_repo).call(day);
}
