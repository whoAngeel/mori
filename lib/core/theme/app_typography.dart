import 'package:flutter/material.dart';

/// The type scale from `docs/design-system.md` §3.
///
/// Two families, both bundled OFL fonts (no `google_fonts`): [_archivo] for
/// display and body, [_plexMono] for figures. PlexMono styles carry
/// [FontFeature.tabularFigures] so amounts and day counts align in a grid.
abstract final class AppTypography {
  static const _archivo = 'Archivo';
  static const _plexMono = 'PlexMono';

  static const _tabular = [FontFeature.tabularFigures()];

  /// The saved amount. PlexMono 44/44, weight 600, tracking −1.0.
  static const displayLarge = TextStyle(
    fontFamily: _plexMono,
    fontSize: 44,
    height: 44 / 44,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.0,
    fontFeatures: _tabular,
  );

  /// Secondary amounts. PlexMono 28/30, weight 600, tracking −0.5.
  static const displaySmall = TextStyle(
    fontFamily: _plexMono,
    fontSize: 28,
    height: 30 / 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    fontFeatures: _tabular,
  );

  /// Screen titles. Archivo 24/28, weight 800, tracking −0.4.
  static const headlineMedium = TextStyle(
    fontFamily: _archivo,
    fontSize: 24,
    height: 28 / 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
  );

  /// Section headers. Archivo 16/20, weight 600.
  static const titleMedium = TextStyle(
    fontFamily: _archivo,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
  );

  /// Running text. Archivo 15/22, weight 400.
  static const bodyMedium = TextStyle(
    fontFamily: _archivo,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
  );

  /// Buttons. Archivo 14/16, weight 600, tracking +0.2.
  static const labelLarge = TextStyle(
    fontFamily: _archivo,
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Eyebrows. Archivo 11/12, weight 600, tracking +1.2. Rendered in small
  /// caps (uppercased at the call site).
  static const labelSmall = TextStyle(
    fontFamily: _archivo,
    fontSize: 11,
    height: 12 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  /// Numbers inside boxes. PlexMono 13/14, weight 400.
  static const numeric = TextStyle(
    fontFamily: _plexMono,
    fontSize: 13,
    height: 14 / 13,
    fontWeight: FontWeight.w400,
    fontFeatures: _tabular,
  );

  /// Assembles a [TextTheme] from the scale, tinting every style [ink].
  static TextTheme textTheme(Color ink) => TextTheme(
        displayLarge: displayLarge.copyWith(color: ink),
        displaySmall: displaySmall.copyWith(color: ink),
        headlineMedium: headlineMedium.copyWith(color: ink),
        titleMedium: titleMedium.copyWith(color: ink),
        bodyMedium: bodyMedium.copyWith(color: ink),
        labelLarge: labelLarge.copyWith(color: ink),
        labelSmall: labelSmall.copyWith(color: ink),
      );
}
