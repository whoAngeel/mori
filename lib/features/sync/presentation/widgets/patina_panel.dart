import 'package:flutter/material.dart';

import '../../../../core/theme/ink_colors.dart';
import 'freshness_label.dart';

/// Wraps the partner's view and stamps the freshness label at the foot.
///
/// The patina (§5) dims the *ink* as the last scan ages, never the text. This
/// panel does not apply the opacity itself: it hands [inkOpacity] to its
/// [builder] so only ink elements (InkBox, bars) fade, while all text —
/// including the exact day count in the label — stays at full contrast. The
/// opacity floor is 0.35 so an old board stays legible, not decorative.
class PatinaPanel extends StatelessWidget {
  /// Creates a patina panel.
  const PatinaPanel({
    super.key,
    required this.lastScan,
    required this.builder,
  });

  /// When the partner was last scanned, or null if never.
  final DateTime? lastScan;

  /// Builds the inked content, receiving the tint opacity to apply to ink only.
  final Widget Function(BuildContext context, double inkOpacity) builder;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final opacity = FreshnessLabel.opacityFor(lastScan);
    final needsSync = FreshnessLabel.needsSyncFor(lastScan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        builder(context, opacity),
        const SizedBox(height: 8),
        Row(
          children: [
            // Label always at full contrast — the redundant, readable signal.
            FreshnessLabel(lastScan: lastScan),
            if (needsSync) ...[
              const SizedBox(width: 8),
              Text(
                '· Sincronizar',
                style: theme.textTheme.labelSmall!
                    .copyWith(color: colors.inkBlack),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
