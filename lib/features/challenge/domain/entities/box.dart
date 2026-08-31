import 'box_status.dart';

/// One box on the board. The [day] is also the amount in MXN (box 45 = \$45).
///
/// [drawnAt] and [paidAt] are local-only and may be null even for a non-free
/// box: that is the normal state of a board recovered via RESTORE (invariant
/// I8). The whole UI must tolerate null dates.
final class Box {
  /// Creates a box.
  const Box({
    required this.day,
    required this.status,
    this.drawnAt,
    this.paidAt,
  });

  /// `1..365`. Also the amount in MXN.
  final int day;

  /// Current state.
  final BoxStatus status;

  /// When it was drawn, or null (unknown after a RESTORE).
  final DateTime? drawnAt;

  /// When it was paid, or null.
  final DateTime? paidAt;

  /// The amount this box represents, in MXN.
  int get amountMxn => day;

  @override
  bool operator ==(Object other) =>
      other is Box &&
      day == other.day &&
      status == other.status &&
      drawnAt == other.drawnAt &&
      paidAt == other.paidAt;

  @override
  int get hashCode => Object.hash(day, status, drawnAt, paidAt);
}
