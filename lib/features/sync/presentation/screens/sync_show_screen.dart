import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../providers/qr_payload_provider.dart';
import '../widgets/qr_plate.dart';

/// Shows this device's SYNC QR for the partner to scan.
///
/// The payload is memoized by stateVersion in [syncQrPayloadProvider], so it is
/// never rebuilt per frame.
class SyncShowScreen extends ConsumerWidget {
  /// Creates the sync-show screen.
  const SyncShowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final payload = ref.watch(syncQrPayloadProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mostrar mi código')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: payload.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (text) {
                  if (text == null) {
                    return const Center(
                      child: Text('No hay reto que compartir.'),
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Eyebrow('Muestra este código'),
                      const SizedBox(height: 8),
                      Text(
                        'Para que tu pareja te vea.',
                        style: theme.textTheme.bodyMedium!
                            .copyWith(color: colors.inkMuted),
                      ),
                      const SizedBox(height: 24),
                      QrPlate(data: text),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
