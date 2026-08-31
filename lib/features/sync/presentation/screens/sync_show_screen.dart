import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../providers/qr_payload_provider.dart';
import '../widgets/max_brightness.dart';
import '../widgets/qr_plate.dart';

/// Shows this device's SYNC QR for the partner to scan.
///
/// The payload is memoized by stateVersion in [syncQrPayloadProvider]. The
/// plate is drawn at its final size straight away and the QR fills in once the
/// payload is built, so nothing flashes or jumps on entry.
class SyncShowScreen extends ConsumerWidget {
  /// Creates the sync-show screen.
  const SyncShowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final payload = ref.watch(syncQrPayloadProvider);
    final text = payload.value;
    final noChallenge = payload.hasValue && text == null;

    return MaxBrightness(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Mostrar mi código')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Eyebrow('Muestra este código'),
                    const SizedBox(height: 8),
                    Text(
                      noChallenge
                          ? 'No hay reto que compartir.'
                          : 'Para que tu pareja te vea.',
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: colors.inkMuted),
                    ),
                    const SizedBox(height: 24),
                    if (payload.hasError)
                      Text(
                        '${payload.error}',
                        style: theme.textTheme.bodyMedium!
                            .copyWith(color: colors.inkBlack),
                      )
                    else if (!noChallenge)
                      QrPlate(data: text ?? ''),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
