import 'package:flutter/material.dart';

import '../theme/ink_colors.dart';

/// A solid ink block button: radius 2, paper-coloured text, no shadow, no
/// ripple. On press the block snaps to perfect registration (offset 0).
///
/// See `docs/design-system.md` §7. Height is 56 dp, or 72 dp when [primary].
class InkButton extends StatefulWidget {
  /// Creates an ink button.
  const InkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.subtitle,
    this.primary = false,
    this.ink,
  });

  /// The button label.
  final String label;

  /// Optional second line (e.g. "2 sorteos pendientes").
  final String? subtitle;

  /// Tapped callback. Null disables the button.
  final VoidCallback? onPressed;

  /// Primary buttons are taller (72 dp).
  final bool primary;

  /// Ink override; defaults to `inkSelf`.
  final Color? ink;

  @override
  State<InkButton> createState() => _InkButtonState();
}

class _InkButtonState extends State<InkButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);
    final enabled = widget.onPressed != null;
    final block = widget.ink ?? colors.inkSelf;
    // The outline sits still; the ink block is offset until pressed.
    final offset = _pressed ? Offset.zero : const Offset(2, 2);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: SizedBox(
          height: widget.primary ? 72 : 56,
          width: double.infinity,
          child: Stack(
            children: [
              // Outline stays in place.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.inkBlack, width: 1.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Ink block, offset until pressed. Alpha carries the disabled
              // dimming — no Opacity layer.
              Positioned.fill(
                child: Transform.translate(
                  offset: offset,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: enabled ? block : colors.inkMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.label.toUpperCase(),
                            style: theme.textTheme.labelLarge!
                                .copyWith(color: colors.paper),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle!,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: colors.paper,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
