import '../entities/partner_snapshot.dart';
import '../repositories/sync_repository.dart';

/// Streams the partner's last snapshot description (or null when never synced).
final class WatchPartnerSnapshot {
  /// Creates the use case over [_repository].
  const WatchPartnerSnapshot(this._repository);

  final SyncRepository _repository;

  /// Emits the current [PartnerSnapshot] (or null) and every change.
  Stream<PartnerSnapshot?> call() => _repository.watchPartnerSnapshot();
}
