import 'package:flutter_test/flutter_test.dart';
import 'package:mori/features/sync/presentation/widgets/freshness_label.dart';

DateTime _daysAgo(int days) =>
    DateTime.now().subtract(Duration(days: days, hours: 1));

void main() {
  group('patina table (design-system §5) — task 7.1', () {
    test('0-2 days: full ink', () {
      expect(FreshnessLabel.opacityFor(_daysAgo(0)), 1.0);
      expect(FreshnessLabel.opacityFor(_daysAgo(2)), 1.0);
    });

    test('3-6 days: 0.72', () {
      expect(FreshnessLabel.opacityFor(_daysAgo(3)), 0.72);
      expect(FreshnessLabel.opacityFor(_daysAgo(6)), 0.72);
    });

    test('7-13 days: 0.52', () {
      expect(FreshnessLabel.opacityFor(_daysAgo(7)), 0.52);
      expect(FreshnessLabel.opacityFor(_daysAgo(13)), 0.52);
    });

    test('14+ days: floor 0.35 and prompts sync', () {
      expect(FreshnessLabel.opacityFor(_daysAgo(14)), 0.35);
      expect(FreshnessLabel.opacityFor(_daysAgo(90)), 0.35);
      expect(FreshnessLabel.needsSyncFor(_daysAgo(14)), isTrue);
      expect(FreshnessLabel.needsSyncFor(_daysAgo(13)), isFalse);
    });

    test('never scanned: full opacity, no sync prompt, its own label', () {
      expect(FreshnessLabel.opacityFor(null), 1.0);
      expect(FreshnessLabel.needsSyncFor(null), isFalse);
      expect(FreshnessLabel.labelFor(null), 'Todavía no escaneas su código');
    });

    test('labels degrade correctly', () {
      expect(FreshnessLabel.labelFor(_daysAgo(0)), 'Impreso hoy');
      expect(FreshnessLabel.labelFor(_daysAgo(1)), 'Impreso ayer');
      expect(FreshnessLabel.labelFor(_daysAgo(8)), 'Impreso hace 8 días');
    });
  });
}
