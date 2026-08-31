import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Forces the screen to full brightness while mounted and restores the previous
/// level on dispose (`docs/design-system.md` §6).
///
/// A bright `plate` under the QR is what cheap cameras need to lock on. The
/// brightness override is scoped to the app, so leaving the screen — by any
/// route, including the back gesture — puts it back. Platforms without
/// brightness control just render the QR at whatever brightness is set.
class MaxBrightness extends StatefulWidget {
  /// Wraps [child] and boosts brightness for as long as it is on screen.
  const MaxBrightness({super.key, required this.child});

  /// The subtree shown at full brightness.
  final Widget child;

  @override
  State<MaxBrightness> createState() => _MaxBrightnessState();
}

class _MaxBrightnessState extends State<MaxBrightness> {
  @override
  void initState() {
    super.initState();
    _boost();
  }

  Future<void> _boost() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1);
    } catch (_) {
      // No brightness control on this platform — the QR still renders.
    }
  }

  @override
  void dispose() {
    // Fire and forget: the widget is going away regardless of the result.
    ScreenBrightness.instance.resetApplicationScreenBrightness().catchError(
      (_) {},
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
