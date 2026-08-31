import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../providers/sync_notifier.dart';
import '../widgets/freshness_label.dart';
import 'sync_scan_screen.dart';
import 'sync_show_screen.dart';

/// The sync hub: the two numbered steps of the ritual and the last-scan date.
///
/// The numbers 1 and 2 belong here: it is a real sequence whose order matters
/// and that people forget (design §6).
class SyncHubScreen extends ConsumerWidget {
  /// Creates the sync hub.
  const SyncHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final snapshot = ref.watch(partnerSnapshotProvider);

    final lastScan = switch (snapshot) {
      AsyncData(:final value) => value == null
          ? 'Todavía no escaneas su código'
          : FreshnessLabel.labelFor(
              DateTime.fromMillisecondsSinceEpoch(value.receivedAtMillis),
            ),
      _ => '',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Sincronizar')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const Eyebrow('Sincronizar'),
                const SizedBox(height: 12),
                Text(
                  'Se hacen dos escaneos: uno para que ella te vea, otro para '
                  'que tú la veas.',
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: colors.inkBlack),
                ),
                const SizedBox(height: 24),
                _Step(
                  number: 1,
                  title: 'Mostrar mi código',
                  subtitle: 'Para que ella te escanee',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SyncShowScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _Step(
                  number: 2,
                  title: 'Escanear el suyo',
                  subtitle: lastScan,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SyncScanScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final int number;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colors.inkBlack, width: 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Text(
              '$number',
              style: theme.textTheme.displaySmall!
                  .copyWith(color: colors.inkSelf),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelLarge!
                        .copyWith(color: colors.inkBlack),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: colors.inkMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
