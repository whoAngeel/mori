import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// The database is the single place that knows about *every* feature table.
// This is the one allowed dependency from `core` into `features`.
import '../../features/counter/data/tables/counter_table.dart';

part 'app_database.g.dart';

/// Application-wide Drift database.
///
/// Register a feature's table here, run `build_runner`, then use it through a
/// DAO or directly from a datasource.
@DriftDatabase(tables: [CounterEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Bump this and add a migration in [migration] whenever a table changes.
  @override
  int get schemaVersion => 1;

  /// `drift_flutter` picks the right implementation per platform and stores the
  /// file under the app's documents directory.
  static QueryExecutor _openConnection() => driftDatabase(name: 'mori_db');
}
