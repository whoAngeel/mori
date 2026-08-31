import 'package:flutter/material.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../domain/entities/box_status.dart';

/// The sealed box — the app's signature element (`docs/design-system.md` §4).
///
/// A stack of two mis-registered layers: a still outline and an ink block
/// offset by a deterministic per-day amount. The three states differ by
/// **shape and fill**, not colour alone (accessibility, §9): free has no block,
/// assigned is outlined ink, paid is solid ink with a knockout number.
class InkBox extends StatelessWidget {
  /// Creates a box for [day] in [status].
  const InkBox({
    super.key,
    required this.day,
    required this.status,
    required this.ink,
    this.size = 24,
    this.opacity = 1.0,
  });

  /// `1..365`, shown as the number and used for the misregistration offset.
  final int day;

  /// The state that decides shape and fill.
  final BoxStatus status;

  /// Which ink this board uses (self or partner).
  final Color ink;

  /// Edge length in dp.
  final double size;

  /// Ink opacity for the patina (partner board). Applied to the ink only.
  final double opacity;

  /// Deterministic per-day registration offset, −2..+2 dp on each axis.
  static Offset misregistration(int day) => Offset(
        ((day * 37) % 5) - 2.0,
        ((day * 53) % 5) - 2.0,
      );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final label = _semanticsLabel();

    return Semantics(
      label: label,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _InkBoxPainter(
            day: day,
            status: status,
            ink: ink.withValues(alpha: opacity),
            rule: colors.rule,
            inkBlack: colors.inkBlack,
            paper: colors.paper,
            muted: colors.inkMuted,
          ),
        ),
      ),
    );
  }

  String _semanticsLabel() {
    final state = switch (status) {
      BoxStatus.free => 'libre',
      BoxStatus.assigned => 'sorteada',
      BoxStatus.paid => 'pagada',
    };
    return 'Día $day, \$$day, $state';
  }
}

class _InkBoxPainter extends CustomPainter {
  const _InkBoxPainter({
    required this.day,
    required this.status,
    required this.ink,
    required this.rule,
    required this.inkBlack,
    required this.paper,
    required this.muted,
  });

  final int day;
  final BoxStatus status;
  final Color ink;
  final Color rule;
  final Color inkBlack;
  final Color paper;
  final Color muted;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = const Radius.circular(2);
    final offset = InkBox.misregistration(day);

    // Ink block (assigned/paid), offset from the outline.
    if (status != BoxStatus.free) {
      final blockRect =
          RRect.fromRectAndRadius(rect.shift(offset), radius);
      final blockPaint = Paint()..color = ink;
      if (status == BoxStatus.assigned) {
        // Outlined block: 2 dp stroke, no fill.
        blockPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
      } else {
        // Solid block.
        blockPaint.style = PaintingStyle.fill;
      }
      canvas.drawRRect(blockRect, blockPaint);
    }

    // Outline stays in place.
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = status == BoxStatus.free ? rule : inkBlack
      ..strokeWidth = status == BoxStatus.free ? 1 : 1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), outlinePaint);

    // The number.
    final numberColor = switch (status) {
      BoxStatus.free => muted,
      BoxStatus.assigned => ink,
      BoxStatus.paid => paper, // knockout
    };
    final weight =
        status == BoxStatus.free ? FontWeight.w400 : FontWeight.w600;
    final tp = TextPainter(
      text: TextSpan(
        text: '$day',
        style: TextStyle(
          fontFamily: 'PlexMono',
          fontSize: size.width * 0.42,
          height: 1,
          fontWeight: weight,
          color: numberColor,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        (size.width - tp.width) / 2 + (status == BoxStatus.paid ? offset.dx : 0),
        (size.height - tp.height) / 2 +
            (status == BoxStatus.paid ? offset.dy : 0),
      ),
    );
  }

  @override
  bool shouldRepaint(_InkBoxPainter old) =>
      old.day != day ||
      old.status != status ||
      old.ink != ink ||
      old.rule != rule;
}
