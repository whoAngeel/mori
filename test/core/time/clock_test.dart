import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/time/clock.dart';

void main() {
  group('toEpochDay', () {
    test('epoch itself is day 0', () {
      expect(toEpochDay(DateTime(1970, 1, 1)), 0);
    });

    test('the next civil day is day 1', () {
      expect(toEpochDay(DateTime(1970, 1, 2)), 1);
    });

    test('ignores the time-of-day component', () {
      expect(toEpochDay(DateTime(1970, 1, 1, 23, 59, 59)), 0);
      expect(toEpochDay(DateTime(1970, 1, 2, 0, 0, 1)), 1);
    });

    test('crosses a month boundary correctly', () {
      final jan31 = toEpochDay(DateTime(2024, 1, 31));
      final feb1 = toEpochDay(DateTime(2024, 2, 1));
      expect(feb1 - jan31, 1);
    });

    test('crosses a year boundary correctly', () {
      final dec31 = toEpochDay(DateTime(2023, 12, 31));
      final jan1 = toEpochDay(DateTime(2024, 1, 1));
      expect(jan1 - dec31, 1);
    });

    test('spans a full non-leap year as 365 days', () {
      final start = toEpochDay(DateTime(2023, 1, 1));
      final end = toEpochDay(DateTime(2024, 1, 1));
      expect(end - start, 365);
    });

    test('spans a full leap year as 366 days', () {
      final start = toEpochDay(DateTime(2024, 1, 1));
      final end = toEpochDay(DateTime(2025, 1, 1));
      expect(end - start, 366);
    });

    test('counts the leap day (2024-02-29) as a real day', () {
      final feb28 = toEpochDay(DateTime(2024, 2, 28));
      final feb29 = toEpochDay(DateTime(2024, 2, 29));
      final mar1 = toEpochDay(DateTime(2024, 3, 1));
      expect(feb29 - feb28, 1);
      expect(mar1 - feb29, 1);
    });

    test('is monotonic across a sequence of civil dates', () {
      var previous = toEpochDay(DateTime(2020, 1, 1));
      for (final date in [
        DateTime(2020, 1, 2),
        DateTime(2020, 2, 1),
        DateTime(2020, 12, 31),
        DateTime(2021, 1, 1),
      ]) {
        final current = toEpochDay(date);
        expect(current, greaterThan(previous));
        previous = current;
      }
    });
  });

  group('SystemClock', () {
    test('todayEpochDay agrees with toEpochDay(now())', () {
      const clock = SystemClock();
      expect(clock.todayEpochDay(), toEpochDay(clock.now()));
    });
  });
}
