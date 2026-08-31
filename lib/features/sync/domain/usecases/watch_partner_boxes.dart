import '../entities/partner_snapshot.dart';
import '../repositories/sync_repository.dart';

/// Streams the partner's replica board (0 or 365 boxes).
final class WatchPartnerBoxes {
  /// Creates the use case over [_repository].
  const WatchPartnerBoxes(this._repository);

  final SyncRepository _repository;

  /// Emits the partner's boxes and every change.
  Stream<List<PartnerBox>> call() => _repository.watchPartnerBoxes();
}
