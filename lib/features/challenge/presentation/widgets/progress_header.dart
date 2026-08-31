import 'package:flutter/material.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../../../core/widgets/amount.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../domain/entities/challenge_progress.dart';

/// The home progress header: the saved amount, a caption, and a progress bar.
/// No shadow, no gradient — the bar is a flat ink fill over the rule colour.
class ProgressHeader extends StatelessWidget {
  /// Creates the header from [progress].
  const ProgressHeader({super.key, required this.progress});

  /// The current progress.
  final ChallengeProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final fraction = progress.committedMxn / ChallengeProgress.totalMxn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('Reto 365 · Día ${progress.challengeDay}'),
        const SizedBox(height: 12),
        Amount(progress.savedMxn),
        const SizedBox(height: 4),
        Text(
          'de ${Amount.format(ChallengeProgress.totalMxn)} · '
          '${progress.drawn} casillas',
          style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 12),
        _ProgressBar(fraction: fraction),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    return SizedBox(
      height: 6,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(color: colors.rule),
              Container(
                width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
                color: colors.inkSelf,
              ),
            ],
          );
        },
      ),
    );
  }
}
