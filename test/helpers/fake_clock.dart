import 'package:mori/core/time/clock.dart';

/// A [Clock] whose "now" is fixed and settable, for deterministic tests —
/// including moving time backwards.
class FakeClock implements Clock {
  /// Starts at [initial].
  FakeClock(this._now);

  DateTime _now;

  /// Overrides the current instant.
  void setNow(DateTime value) => _now = value;

  @override
  DateTime now() => _now;

  @override
  int todayEpochDay() => toEpochDay(_now);
}
