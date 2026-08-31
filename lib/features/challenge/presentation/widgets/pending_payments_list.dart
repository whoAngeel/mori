import 'package:flutter/material.dart';

import '../../../../core/theme/ink_colors.dart';
import '../../../../core/widgets/amount.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/empty_plate.dart';
import '../../domain/entities/box.dart';
import '../../domain/entities/box_status.dart';
import 'ink_box.dart';

/// The "por pagar" list: assigned-but-unpaid boxes, oldest first.
///
/// Sorts by [Box.drawnAt] with a fallback to [Box.day] when the date is null —
/// the normal state after a RESTORE (invariant I8). The age label degrades to
/// "Sin fecha" rather than crashing.
class PendingPaymentsList extends StatelessWidget {
  /// Creates the list from [boxes] with a [onPay] callback.
  const PendingPaymentsList({
    super.key,
    required this.boxes,
    required this.onPay,
  });

  /// All boxes; this widget filters to the pending ones.
  final List<Box> boxes;

  /// Called with the day to mark paid.
  final void Function(int day) onPay;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final pending = boxes
        .where((b) => b.status == BoxStatus.assigned)
        .toList()
      ..sort(_byAgeThenDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('Por pagar · ${pending.length}'),
        const SizedBox(height: 12),
        if (pending.isEmpty)
          const EmptyPlate('Cuando sortees, lo pendiente aparece aquí.')
        else
          ...pending.map((b) => _PendingRow(
                box: b,
                ink: colors.inkSelf,
                onPay: () => onPay(b.day),
              )),
      ],
    );
  }

  static int _byAgeThenDay(Box a, Box b) {
    final da = a.drawnAt;
    final db = b.drawnAt;
    if (da != null && db != null) return da.compareTo(db);
    if (da != null) return -1; // dated ones first
    if (db != null) return 1;
    return a.day.compareTo(b.day); // both null: fall back to day
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({
    required this.box,
    required this.ink,
    required this.onPay,
  });

  final Box box;
  final Color ink;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<InkColors>()!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          InkBox(day: box.day, status: box.status, ink: ink, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Amount.format(box.amountMxn),
                  style: theme.textTheme.displaySmall!
                      .copyWith(color: colors.inkBlack, fontSize: 18),
                ),
                Text(
                  _ageLabel(box.drawnAt),
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: colors.inkMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Ya lo aparté, día ${box.day}',
            child: GestureDetector(
              onTap: onPay,
              child: Text(
                'Ya lo aparté',
                style: theme.textTheme.labelLarge!.copyWith(color: ink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _ageLabel(DateTime? drawnAt) {
    if (drawnAt == null) return 'Sin fecha';
    final days = DateTime.now().difference(drawnAt).inDays;
    return switch (days) {
      <= 0 => 'Sorteado hoy',
      1 => 'Sorteado ayer',
      _ => 'Sorteado hace $days días',
    };
  }
}
