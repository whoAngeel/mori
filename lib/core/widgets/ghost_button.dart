import 'package:flutter/material.dart';

import '../theme/ink_colors.dart';

/// A secondary action: a 1.5 dp `inkBlack` outline with no fill, no shadow, no
/// ripple. See `docs/design-system.md` §7.
class GhostButton extends StatelessWidget {
  /// Creates a ghost button.
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  /// The button label.
  final String label;

  /// Tapped callback. Null disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final ink = enabled ? colors.inkBlack : colors.inkMuted;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 56,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: ink, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelLarge!.copyWith(color: ink),
          ),
        ),
      ),
    );
  }
}
