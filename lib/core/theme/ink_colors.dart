import 'package:flutter/material.dart';

/// The two-ink palette, exposed as a [ThemeExtension] so widgets read colours
/// from the theme instead of naming literals.
///
/// Usage: `Theme.of(context).extension<InkColors>()!.inkSelf`.
///
/// Hex values and their WCAG contrast ratios are fixed in
/// `docs/design-system.md` §2. They are not tweaked by eye: if one changes, the
/// contrast is recomputed.
@immutable
final class InkColors extends ThemeExtension<InkColors> {
  /// Creates a palette from the eight design tokens.
  const InkColors({
    required this.paper,
    required this.plate,
    required this.inkBlack,
    required this.inkMuted,
    required this.inkSelf,
    required this.inkPartner,
    required this.overprint,
    required this.rule,
  });

  /// App background.
  final Color paper;

  /// Elevated surfaces (cards, sheets).
  final Color plate;

  /// All text. Press black, not `#000`.
  final Color inkBlack;

  /// Secondary text and free-box numbers.
  final Color inkMuted;

  /// Ink A — you. Fills and large figures.
  final Color inkSelf;

  /// Ink B — your partner.
  final Color inkPartner;

  /// Only in the joint view, where the two inks overlap.
  final Color overprint;

  /// 1 dp separators and rules.
  final Color rule;

  /// Light theme tokens (`docs/design-system.md` §2).
  static const light = InkColors(
    paper: Color(0xFFE8E9E3),
    plate: Color(0xFFF5F5F0),
    inkBlack: Color(0xFF1A1A1E),
    inkMuted: Color(0xFF66665F),
    inkSelf: Color(0xFFB3243F),
    inkPartner: Color(0xFF005E96),
    overprint: Color(0xFF47265E),
    rule: Color(0xFFC8C9C1),
  );

  /// Dark theme tokens (`docs/design-system.md` §2).
  static const dark = InkColors(
    paper: Color(0xFF151518),
    plate: Color(0xFF1E1E22),
    inkBlack: Color(0xFFE8E8E2),
    inkMuted: Color(0xFF9A9A93),
    inkSelf: Color(0xFFFF6B78),
    inkPartner: Color(0xFF3FA3E0),
    overprint: Color(0xFFB79BD6),
    rule: Color(0xFF33333A),
  );

  @override
  InkColors copyWith({
    Color? paper,
    Color? plate,
    Color? inkBlack,
    Color? inkMuted,
    Color? inkSelf,
    Color? inkPartner,
    Color? overprint,
    Color? rule,
  }) {
    return InkColors(
      paper: paper ?? this.paper,
      plate: plate ?? this.plate,
      inkBlack: inkBlack ?? this.inkBlack,
      inkMuted: inkMuted ?? this.inkMuted,
      inkSelf: inkSelf ?? this.inkSelf,
      inkPartner: inkPartner ?? this.inkPartner,
      overprint: overprint ?? this.overprint,
      rule: rule ?? this.rule,
    );
  }

  @override
  InkColors lerp(covariant InkColors? other, double t) {
    if (other == null) return this;
    return InkColors(
      paper: Color.lerp(paper, other.paper, t)!,
      plate: Color.lerp(plate, other.plate, t)!,
      inkBlack: Color.lerp(inkBlack, other.inkBlack, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkSelf: Color.lerp(inkSelf, other.inkSelf, t)!,
      inkPartner: Color.lerp(inkPartner, other.inkPartner, t)!,
      overprint: Color.lerp(overprint, other.overprint, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
    );
  }
}
