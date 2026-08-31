import '../../../../core/utils/result.dart';
import '../entities/box.dart';

/// The challenge feature's data contract. Implemented in Data, used only by the
/// Domain use cases.
///
/// Every mutation bumps `stateVersion` in the same transaction (invariant I4).
abstract interface class ChallengeRepository {
  /// Emits the 365 boxes, ordered by day, and every change.
  Stream<List<Box>> watchBoxes();

  /// Draws one random free box: marks it assigned, stamps the draw time and
  /// bumps `stateVersion`, all in one transaction.
  ///
  /// Fails with `NoBoxesLeft` when none are free, or `NoDrawsPending` when no
  /// draws are available today.
  Future<Result<Box>> drawNextBox();

  /// Marks a drawn box as paid.
  Future<Result<void>> markPaid(int day);

  /// Reverts a paid box back to assigned (the only backwards transition, I3).
  Future<Result<void>> unmarkPaid(int day);
}
