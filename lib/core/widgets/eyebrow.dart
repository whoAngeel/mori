import 'package:flutter/material.dart';

import '../theme/ink_colors.dart';

/// A section eyebrow: `labelSmall` in small caps with tracking.
///
/// Uppercased and tracked together — one without the other reads as an
/// accident (`docs/design-system.md` §3).
class Eyebrow extends StatelessWidget {
  /// Creates an eyebrow showing [text].
  const Eyebrow(this.text, {super.key, this.color});

  /// The label; it is uppercased before display.
  final String text;

  /// Optional ink override; defaults to `inkBlack`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).extension<InkColors>()!;
    return Text(
      text.toUpperCase(),
      style: Theme.of(context)
          .textTheme
          .labelSmall!
          .copyWith(color: color ?? ink.inkBlack),
    );
  }
}
