import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/random/random_providers.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/sync_local_data_source.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/entities/partner_snapshot.dart';
import '../../domain/entities/sync_outcome.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/usecases/apply_restore_payload.dart';
import '../../domain/usecases/apply_sync_payload.dart';
import '../../domain/usecases/build_restore_payload.dart';
import '../../domain/usecases/watch_partner_boxes.dart';
import '../../domain/usecases/watch_partner_snapshot.dart';

part 'sync_notifier.g.dart';

// --- Dependency injection ---

/// The sync datasource.
@riverpod
SyncLocalDataSource syncLocalDataSource(Ref ref) =>
    SyncLocalDataSource(ref.watch(appDatabaseProvider));

/// The sync repository, wired with the clock and RNG.
@riverpod
SyncRepository syncRepository(Ref ref) => SyncRepositoryImpl(
      ref.watch(syncLocalDataSourceProvider),
      ref.watch(clockProvider),
      ref.watch(randomProvider),
    );

/// Streams the partner's last snapshot description (or null).
@riverpod
Stream<PartnerSnapshot?> partnerSnapshot(Ref ref) =>
    WatchPartnerSnapshot(ref.watch(syncRepositoryProvider)).call();

/// Streams the partner's replica board.
@riverpod
Stream<List<PartnerBox>> partnerBoxes(Ref ref) =>
    WatchPartnerBoxes(ref.watch(syncRepositoryProvider)).call();

/// Coordinates the scan/apply commands.
@riverpod
class SyncController extends _$SyncController {
  @override
  void build() {}

  SyncRepository get _repo => ref.read(syncRepositoryProvider);

  /// Applies a scanned SYNC payload.
  Future<Result<SyncOutcome>> applySync(String text) =>
      ApplySyncPayload(_repo).call(text);

  /// Applies a scanned RESTORE payload with the recovering person's name.
  Future<Result<SyncOutcome>> applyRestore({
    required String text,
    required String localName,
  }) =>
      ApplyRestorePayload(_repo).call(
        ApplyRestoreParams(scannedText: text, localName: localName),
      );

  /// Builds a RESTORE payload for the partner.
  Future<Result<String>> buildRestore() =>
      BuildRestorePayload(_repo).call(const NoParams());
}
