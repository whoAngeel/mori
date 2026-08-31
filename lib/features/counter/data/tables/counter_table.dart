import 'package:drift/drift.dart';

/// Drift table definition for the counter feature.
///
/// Registered in `core/database/app_database.dart`. The template keeps a single
/// row (`id == 1`) that holds the running value.
class CounterEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get value => integer().withDefault(const Constant(0))();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
