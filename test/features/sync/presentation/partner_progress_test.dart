import 'package:flutter_test/flutter_test.dart';
import 'package:mori/features/sync/domain/entities/box_state.dart';
import 'package:mori/features/sync/domain/entities/partner_snapshot.dart';
import 'package:mori/features/sync/presentation/partner_progress.dart';

List<PartnerBox> _boxes({int assigned = 0, int paid = 0}) => [
  for (var day = 1; day <= 365; day++)
    PartnerBox(
      day: day,
      status: day <= paid
          ? WireBoxState.paid
          : day <= assigned
          ? WireBoxState.assigned
          : WireBoxState.free,
    ),
];

PartnerSnapshot _snapshot({required int startEpochDay}) => PartnerSnapshot(
  stateVersion: 1,
  installId: 1,
  startEpochDay: startEpochDay,
  receivedAtMillis: 0,
);

void main() {
  group('PartnerProgress (task 7.2)', () {
    test('money math over the partner replica', () {
      final p = PartnerProgress.from(
        boxes: _boxes(assigned: 3, paid: 2),
        snapshot: _snapshot(startEpochDay: 20000),
        todayEpochDay: 20005,
      );
      expect(p.paid, 2);
      expect(p.drawn, 3);
      expect(p.savedMxn, 1 + 2);
      expect(p.committedMxn, 1 + 2 + 3);
    });

    test('challenge day uses the partner start date, not the local one', () {
      // Partner started 9 days before "today": their day is 10, regardless of
      // any local start date.
      final p = PartnerProgress.from(
        boxes: _boxes(),
        snapshot: _snapshot(startEpochDay: 20000),
        todayEpochDay: 20009,
      );
      expect(p.challengeDay, 10);
    });

    test('a different partner start date yields a different day', () {
      final earlier = PartnerProgress.from(
        boxes: _boxes(),
        snapshot: _snapshot(startEpochDay: 19990),
        todayEpochDay: 20009,
      );
      expect(earlier.challengeDay, 20); // started 10 days earlier
    });

    test('challenge day is clamped to [1, 365]', () {
      final future = PartnerProgress.from(
        boxes: _boxes(),
        snapshot: _snapshot(startEpochDay: 20009),
        todayEpochDay: 20000, // before their start
      );
      expect(future.challengeDay, 1);
    });
  });
}
