import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pairing/domain/entities/pairing_state.dart';
import '../../../pairing/presentation/providers/pairing_notifier.dart';
import 'sync_notifier.dart';

part 'discrepancy_provider.g.dart';

/// True when the partner's snapshot start date differs from the local one
/// (§8.4). The snapshot was still applied; this drives a persistent notice
/// shown until the challenge is reset.
@riverpod
Future<bool> startDateMismatch(Ref ref) async {
  final pairing = await ref.watch(pairingStateProvider.future);
  final snapshot = await ref.watch(partnerSnapshotProvider.future);
  if (pairing is! Paired || snapshot == null) return false;
  return snapshot.startEpochDay != pairing.startEpochDay;
}

/// True when the partner's snapshot installId differs from the one recorded at
/// pairing time: the partner reinstalled the app (§7.10). Drives a persistent
/// reinstall notice.
@riverpod
Future<bool> partnerReinstalled(Ref ref) async {
  final pairing = await ref.watch(pairingStateProvider.future);
  final snapshot = await ref.watch(partnerSnapshotProvider.future);
  if (pairing is! Paired || snapshot == null) return false;
  final pairedInstallId = pairing.partnerInstallId;
  if (pairedInstallId == null) return false;
  return snapshot.installId != pairedInstallId;
}
