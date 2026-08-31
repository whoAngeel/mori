import 'package:flutter/material.dart';

import '../theme/ink_colors.dart';

/// An empty state: a dashed outline and a line that invites action, never a
/// little drawing (`docs/design-system.md` §7, §8).
class EmptyPlate extends StatelessWidget {
  /// Creates an empty plate showing [message].
  const EmptyPlate(this.message, {super.key});

  /// The inviting sentence.
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    return CustomPaint(
      painter: _DashedBorderPainter(colors.rule),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium!.copyWith(color: colors.inkMuted),
          ),
        ),
      ),
    );
  }
}

/// Paints a 1 dp dashed rectangle with radius 2. No fill.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dash = 4.0;
    const gap = 4.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(2),
    );
    final path = Path()..addRRect(rect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
