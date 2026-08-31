import 'package:flutter/material.dart';

/// One mechanical digit reel, like an odometer wheel.
///
/// [value] is a continuous position: the reel shows `value % 10`, and the
/// neighbouring digits scroll past as it moves. The parent animates [value]
/// from `0` up to `turns * 10 + targetDigit` so the wheel spins whole turns
/// and settles on the target — flat ink on paper, no blur, cheap to paint
/// (three `Text`s clipped to one digit height).
class DigitReel extends StatelessWidget {
  /// Creates a reel at continuous position [value].
  const DigitReel({
    super.key,
    required this.value,
    required this.style,
    required this.height,
  });

  /// Continuous wheel position; the visible digit is `value % 10`.
  final double value;

  /// Text style for the digits (PlexMono, tabular).
  final TextStyle style;

  /// Height of a single digit cell, in logical pixels.
  final double height;

  @override
  Widget build(BuildContext context) {
    final base = value.floor();
    return ClipRect(
      child: SizedBox(
        height: height,
        width: height * 0.62,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = base - 1; i <= base + 1; i++)
              Positioned(
                left: 0,
                right: 0,
                top: (i - value) * height,
                height: height,
                child: Center(
                  child: Text('${i % 10}', style: style),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
