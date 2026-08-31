import 'package:flutter/material.dart';

import '../../../../core/theme/ink_colors.dart';

/// The "impreso hace N días" label. Always at full contrast (`inkBlack`): the
/// patina dims the ink, never the text, so the exact day count is always
/// readable (`docs/design-system.md` §5).
///
/// [now] is passed in rather than read from `DateTime.now()` so the label is
/// driven by the app [Clock] and stays testable. The protocol tolerates this
/// label drifting if the system clock moves — it never feeds a merge decision.
class FreshnessLabel extends StatelessWidget {
  /// Creates a freshness label from the last scan instant (or null) and [now].
  const FreshnessLabel({super.key, required this.lastScan, required this.now});

  /// When the partner was last scanned, or null if never.
  final DateTime? lastScan;

  /// The current instant, from the app clock.
  final DateTime now;

  /// The label text for a given last-scan instant (null = never).
  static String labelFor(DateTime? lastScan, {required DateTime now}) {
    if (lastScan == null) return 'Todavía no escaneas su código';
    final days = now.difference(lastScan).inDays;
    return switch (days) {
      <= 0 => 'Impreso hoy',
      1 => 'Impreso hace 1 día',
      _ => 'Impreso hace $days días',
    };
  }

  /// The tint opacity for the patina, by age in days (§5). Floor 0.35.
  static double opacityFor(DateTime? lastScan, {required DateTime now}) {
    if (lastScan == null) return 1.0;
    final days = now.difference(lastScan).inDays;
    return switch (days) {
      < 3 => 1.0,
      < 7 => 0.72,
      < 14 => 0.52,
      _ => 0.35,
    };
  }

  /// True once the last scan is 14 days old or more: the label adds a
  /// "Sincronizar" prompt (§5).
  static bool needsSyncFor(DateTime? lastScan, {required DateTime now}) {
    if (lastScan == null) return false;
    return now.difference(lastScan).inDays >= 14;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    return Text(
      labelFor(lastScan, now: now),
      style: Theme.of(
        context,
      ).textTheme.labelSmall!.copyWith(color: colors.inkBlack),
    );
  }
}
