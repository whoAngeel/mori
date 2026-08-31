import '../entities/pairing_state.dart';
import '../repositories/pairing_repository.dart';

/// Streams the pairing state so the router and UI can react to it.
final class WatchPairingState {
  /// Creates the use case over [_repository].
  const WatchPairingState(this._repository);

  final PairingRepository _repository;

  /// Emits the current [PairingState] and every change.
  Stream<PairingState> call() => _repository.watchPairingState();
}
