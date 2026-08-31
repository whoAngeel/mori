import 'box_state.dart';

/// What the local device knows about the partner's last accepted snapshot.
///
/// Null (absent) means no sync has ever happened. See `docs/data-model.md`
/// §2.4.
final class PartnerSnapshot {
  /// Creates a partner snapshot description.
  const PartnerSnapshot({
    required this.stateVersion,
    required this.installId,
    required this.startEpochDay,
    required this.receivedAtMillis,
  });

  /// From the last accepted snapshot.
  final int stateVersion;

  /// The partner's install id, used to detect reinstalls.
  final int installId;

  /// The partner's own start date, from their payload.
  final int startEpochDay;

  /// Local clock at receive time — display only, never a merge input.
  final int receivedAtMillis;
}

/// One box of the partner's replica board.
final class PartnerBox {
  /// Creates a partner box.
  const PartnerBox({required this.day, required this.status});

  /// `1..365`.
  final int day;

  /// The box state.
  final WireBoxState status;
}
