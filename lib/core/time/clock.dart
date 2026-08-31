import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Source of "now" for the whole app, injected so tests can control time.
///
/// The clock feeds exactly two things: the pending-draws calculation and the
/// "printed N days ago" label. No merge decision ever consults it.
abstract interface class Clock {
  /// The current instant.
  DateTime now();

  /// Today as a civil day count: whole days since 1970-01-01 UTC.
  int todayEpochDay();
}

/// Production [Clock] backed by the device wall clock.
final class SystemClock implements Clock {
  /// Creates a clock reading the real system time.
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  int todayEpochDay() => toEpochDay(DateTime.now());
}

/// Converts a local instant to a civil epoch-day count.
///
/// The value is normalised to the *civil* date and then to UTC midnight, so it
/// counts calendar days rather than 24-hour periods. Never call `toUtc()` on an
/// instant for this: that shifts the day near midnight.
int toEpochDay(DateTime local) =>
    DateTime.utc(local.year, local.month, local.day).millisecondsSinceEpoch ~/
    86400000;

/// The app-wide [Clock]. Override in tests with a fake implementation.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();
