import 'package:flutter_test/flutter_test.dart';
import 'package:mori/features/sync/presentation/widgets/freshness_label.dart';

final _now = DateTime(2026, 8, 31, 12);

DateTime _daysAgo(int days) => _now.subtract(Duration(days: days, hours: 1));

void main() {
  group('patina table (design-system §5) — task 7.1', () {
    test('0-2 days: full ink', () {
      expect(FreshnessLabel.opacityFor(_daysAgo(0), now: _now), 1.0);
      expect(FreshnessLabel.opacityFor(_daysAgo(2), now: _now), 1.0);
    });

    test('3-6 days: 0.72', () {
      expect(FreshnessLabel.opacityFor(_daysAgo(3), now: _now), 0.72);
      expect(FreshnessLabel.opacityFor(_daysAgo(6), now: _now), 0.72);
    });

    test('7-13 days: 0.52', () {
      expect(FreshnessLabel.opacityFor(_daysAgo(7), now: _now), 0.52);
      expect(FreshnessLabel.opacityFor(_daysAgo(13), now: _now), 0.52);
    });

    test('14+ days: floor 0.35 and prompts sync', () {
      expect(FreshnessLabel.opacityFor(_daysAgo(14), now: _now), 0.35);
      expect(FreshnessLabel.opacityFor(_daysAgo(90), now: _now), 0.35);
      expect(FreshnessLabel.needsSyncFor(_daysAgo(14), now: _now), isTrue);
      expect(FreshnessLabel.needsSyncFor(_daysAgo(13), now: _now), isFalse);
    });

    test('never scanned: full opacity, no sync prompt, its own label', () {
      expect(FreshnessLabel.opacityFor(null, now: _now), 1.0);
      expect(FreshnessLabel.needsSyncFor(null, now: _now), isFalse);
      expect(
        FreshnessLabel.labelFor(null, now: _now),
        'Todavía no escaneas su código',
      );
    });

    test('labels degrade correctly', () {
      expect(FreshnessLabel.labelFor(_daysAgo(0), now: _now), 'Impreso hoy');
      expect(
        FreshnessLabel.labelFor(_daysAgo(1), now: _now),
        'Impreso hace 1 día',
      );
      expect(
        FreshnessLabel.labelFor(_daysAgo(8), now: _now),
        'Impreso hace 8 días',
      );
    });
  });
}
