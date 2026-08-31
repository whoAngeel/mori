import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'ink_colors.dart';

/// Central theme definition. Colour and typography decisions live here and in
/// [InkColors] / [AppTypography], never in widgets.
///
/// The [ColorScheme] is built by hand from the design tokens — no
/// `ColorScheme.fromSeed`, which would invent colours off a single seed.
abstract final class AppTheme {
  /// Light theme, assembled from [InkColors.light].
  static ThemeData get light => _build(InkColors.light, Brightness.light);

  /// Dark theme, assembled from [InkColors.dark].
  static ThemeData get dark => _build(InkColors.dark, Brightness.dark);

  static ThemeData _build(InkColors ink, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: ink.inkSelf,
      onPrimary: ink.paper,
      secondary: ink.inkPartner,
      onSecondary: ink.paper,
      error: ink.inkSelf,
      onError: ink.paper,
      surface: ink.plate,
      onSurface: ink.inkBlack,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink.paper,
      canvasColor: ink.paper,
      textTheme: AppTypography.textTheme(ink.inkBlack),
      dividerColor: ink.rule,
      extensions: [ink],
    );
  }
}
