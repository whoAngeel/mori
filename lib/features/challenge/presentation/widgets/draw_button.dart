import 'package:flutter/material.dart';

import '../../../../core/widgets/ink_button.dart';
import '../../domain/entities/challenge_progress.dart';

/// The primary draw action, with its pending count as a subtitle.
///
/// Disabled while a draw is in flight ([busy]), when there are no pending
/// draws, or when the board is complete — the button carries the exact copy
/// from `docs/design-system.md` §8.
class DrawButton extends StatelessWidget {
  /// Creates the draw button.
  const DrawButton({
    super.key,
    required this.progress,
    required this.busy,
    required this.onDraw,
  });

  /// Current progress (for the pending count and completion).
  final ChallengeProgress progress;

  /// True while a draw is running.
  final bool busy;

  /// Tapped callback.
  final VoidCallback onDraw;

  @override
  Widget build(BuildContext context) {
    if (progress.isComplete) {
      return InkButton(
        label: 'Terminaste los 365',
        subtitle: Amount65795Note.text,
        primary: true,
        onPressed: null,
      );
    }

    final pending = progress.pendingDraws;
    final enabled = !busy && pending > 0;
    final subtitle = switch (pending) {
      0 => 'Vuelve mañana por el tuyo',
      1 => '1 sorteo pendiente',
      _ => '$pending sorteos pendientes',
    };

    return InkButton(
      label: busy ? 'Un momento' : 'Sortear',
      subtitle: subtitle,
      primary: true,
      onPressed: enabled ? onDraw : null,
    );
  }
}

/// The completion note text, kept next to the button copy.
abstract final class Amount65795Note {
  /// "$66,795." with a thousands separator.
  static const text = r'$66,795.';
}
