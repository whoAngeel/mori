import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../pairing/domain/entities/pairing_state.dart';
import '../../../pairing/presentation/providers/pairing_notifier.dart';
import '../../domain/usecases/build_sync_payload.dart';
import 'sync_notifier.dart';

part 'qr_payload_provider.g.dart';

/// The SYNC QR text, memoized by `stateVersion`.
///
/// It only recomputes when the local `stateVersion` changes (a mutation), never
/// per frame (§10, design §6). Watching [pairingStateProvider] gives the
/// dependency on stateVersion for free.
@riverpod
Future<String?> syncQrPayload(Ref ref) async {
  // Watching pairing state carries the stateVersion, so this provider rebuilds
  // on every local mutation (and no more often).
  final pairing = await ref.watch(pairingStateProvider.future);
  if (pairing is! Paired) return null;

  final result = await BuildSyncPayload(
    ref.watch(syncRepositoryProvider),
  ).call(const NoParams());
  return switch (result) {
    Ok(:final value) => value,
    Err() => null,
  };
}
