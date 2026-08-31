import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ink_colors.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/widgets/amount.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../pairing/domain/entities/pairing_state.dart';
import '../../../pairing/presentation/providers/pairing_notifier.dart';
import '../partner_progress.dart';
import '../providers/sync_notifier.dart';
import 'patina_panel.dart';

/// The partner's mini-view on the home screen: their progress under the patina,
/// plus a Sincronizar action. Shows an honest empty state before the first
/// scan.
class PartnerPanel extends ConsumerWidget {
  /// Creates the partner panel.
  const PartnerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final snapshotAsync = ref.watch(partnerSnapshotProvider);
    final boxesAsync = ref.watch(partnerBoxesProvider);
    final clock = ref.watch(clockProvider);

    final partnerName = switch (ref.watch(pairingStateProvider).value) {
      Paired(:final partnerName) => partnerName,
      _ => null,
    };

    final snapshot = snapshotAsync.value;
    final boxes = boxesAsync.value ?? const [];

    if (snapshot == null) {
      // Never synced: the honest empty state.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(partnerName ?? 'Tu pareja'),
          const SizedBox(height: 8),
          Text(
            'Todavía no escaneas su código',
            style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 12),
          GhostButton(
            label: 'Sincronizar',
            onPressed: () => context.goNamed(AppRoute.sync.name),
          ),
        ],
      );
    }

    final lastScan =
        DateTime.fromMillisecondsSinceEpoch(snapshot.receivedAtMillis);
    final progress = PartnerProgress.from(
      boxes: boxes,
      snapshot: snapshot,
      todayEpochDay: clock.todayEpochDay(),
    );

    return PatinaPanel(
      lastScan: lastScan,
      builder: (context, inkOpacity) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow('${partnerName ?? 'Tu pareja'} · Día ${progress.challengeDay}'),
            const SizedBox(height: 8),
            Amount(
              progress.savedMxn,
              style: theme.textTheme.displaySmall,
              // Partner ink under the patina: opacity applies to ink only.
              color: colors.inkPartner.withValues(alpha: inkOpacity),
            ),
            const SizedBox(height: 4),
            Text(
              '${progress.drawn} casillas',
              style:
                  theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 8),
            _PartnerBar(
              fraction: progress.committedMxn / 66795,
              ink: colors.inkPartner.withValues(alpha: inkOpacity),
            ),
            const SizedBox(height: 8),
            GhostButton(
              label: 'Ver su tablero',
              onPressed: () => context.goNamed(AppRoute.partner.name),
            ),
          ],
        );
      },
    );
  }
}

class _PartnerBar extends StatelessWidget {
  const _PartnerBar({required this.fraction, required this.ink});

  final double fraction;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    return SizedBox(
      height: 6,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Container(color: colors.rule),
            Container(
              width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
              color: ink,
            ),
          ],
        ),
      ),
    );
  }
}
