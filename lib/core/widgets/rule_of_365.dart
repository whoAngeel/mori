import 'package:flutter/material.dart';

import '../theme/ink_colors.dart';

/// The 365 tick marks at the foot of the board: 1 dp each, inked for the done
/// days. The second place the number 365 becomes something you see rather than
/// read (`docs/design-system.md` §6). Appears only on the board.
class RuleOf365 extends StatelessWidget {
  /// Creates the rule; [doneDays] is the set of drawn day numbers.
  const RuleOf365({
    super.key,
    required this.doneDays,
    required this.ink,
    this.height = 24,
  });

  /// The days (1..365) that are drawn.
  final Set<int> doneDays;

  /// Ink for the done ticks.
  final Color ink;

  /// Rule height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _RulePainter(
          doneDays: doneDays,
          ink: ink,
          rule: colors.rule,
        ),
      ),
    );
  }
}

class _RulePainter extends CustomPainter {
  const _RulePainter({
    required this.doneDays,
    required this.ink,
    required this.rule,
  });

  final Set<int> doneDays;
  final Color ink;
  final Color rule;

  @override
  void paint(Canvas canvas, Size size) {
    const total = 365;
    final step = size.width / total;
    for (var day = 1; day <= total; day++) {
      final x = (day - 1) * step;
      final done = doneDays.contains(day);
      final paint = Paint()
        ..color = done ? ink : rule
        ..strokeWidth = 1;
      final tickHeight = done ? size.height : size.height * 0.6;
      canvas.drawLine(
        Offset(x, size.height - tickHeight),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RulePainter old) =>
      old.doneDays.length != doneDays.length || old.ink != ink;
}
