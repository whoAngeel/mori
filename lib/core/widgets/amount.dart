import 'package:flutter/material.dart';

import '../theme/ink_colors.dart';

/// A peso amount in PlexMono with tabular figures and a thousands separator.
/// Always `$`, never decimals — these are whole pesos (`docs/design-system.md`
/// §7).
class Amount extends StatelessWidget {
  /// Creates an amount widget for [mxn].
  const Amount(this.mxn, {super.key, this.style, this.color});

  /// The value in whole MXN.
  final int mxn;

  /// Optional text style; defaults to `displayLarge`.
  final TextStyle? style;

  /// Optional ink override.
  final Color? color;

  /// Formats [value] as `$1,234` with a comma thousands separator.
  static String format(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final sign = value < 0 ? '-' : '';
    return '$sign\$$buffer';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final base = style ?? Theme.of(context).textTheme.displayLarge!;
    return Text(
      format(mxn),
      style: base.copyWith(color: color ?? colors.inkSelf),
    );
  }
}
