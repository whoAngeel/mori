import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/theme/ink_colors.dart';

/// WCAG 2.x relative luminance of an sRGB colour.
///
/// Channels are linearised per the spec, then weighted. See
/// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
double _relativeLuminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  final r = channel((c.r * 255).round() / 255);
  final g = channel((c.g * 255).round() / 255);
  final b = channel((c.b * 255).round() / 255);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// WCAG contrast ratio between two colours: `(L_light + 0.05) / (L_dark + 0.05)`.
double _contrast(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // This is an arithmetic guard, not a visual test: it stops someone from
  // "adjusting a colour" and silently breaking AA. Each expected minimum is the
  // ratio annotated in docs/design-system.md §2, checked with a small margin.
  const tolerance = 0.15;

  void expectContrast(String label, Color fg, Color bg, double annotated) {
    final ratio = _contrast(fg, bg);
    expect(
      ratio,
      greaterThanOrEqualTo(annotated - tolerance),
      reason:
          '$label: got ${ratio.toStringAsFixed(2)}:1, '
          'expected >= ${annotated.toStringAsFixed(2)}:1',
    );
  }

  group('Light theme contrast (design-system §2)', () {
    const c = InkColors.light;

    test('inkBlack on paper >= 14.2', () {
      expectContrast('inkBlack/paper', c.inkBlack, c.paper, 14.2);
    });

    test('inkMuted on paper >= 4.74', () {
      expectContrast('inkMuted/paper', c.inkMuted, c.paper, 4.74);
    });

    test('inkSelf on paper >= 5.31', () {
      expectContrast('inkSelf/paper', c.inkSelf, c.paper, 5.31);
    });

    test('inkPartner on paper >= 5.65', () {
      expectContrast('inkPartner/paper', c.inkPartner, c.paper, 5.65);
    });

    test('overprint on paper >= 9.9', () {
      expectContrast('overprint/paper', c.overprint, c.paper, 9.9);
    });

    test('paper on inkSelf >= 5.31 (knockout text)', () {
      expectContrast('paper/inkSelf', c.paper, c.inkSelf, 5.31);
    });

    test('paper on inkPartner >= 5.65 (knockout text)', () {
      expectContrast('paper/inkPartner', c.paper, c.inkPartner, 5.65);
    });
  });

  group('Dark theme contrast (design-system §2)', () {
    const c = InkColors.dark;

    test('inkBlack on paper >= 14.8', () {
      expectContrast('inkBlack/paper', c.inkBlack, c.paper, 14.8);
    });

    test('inkMuted on paper >= 6.44', () {
      expectContrast('inkMuted/paper', c.inkMuted, c.paper, 6.44);
    });

    test('inkSelf on paper >= 6.62', () {
      expectContrast('inkSelf/paper', c.inkSelf, c.paper, 6.62);
    });

    test('inkPartner on paper >= 6.53', () {
      expectContrast('inkPartner/paper', c.inkPartner, c.paper, 6.53);
    });

    test('overprint on paper >= 7.53', () {
      expectContrast('overprint/paper', c.overprint, c.paper, 7.53);
    });
  });
}
