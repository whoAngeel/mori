import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// The database is the single place that knows about *every* feature table.
// This is the one allowed dependency from `core` into `features`.
import '../../features/challenge/data/tables/own_boxes_table.dart';
import '../../features/pairing/data/tables/challenge_config_table.dart';
import '../../features/sync/data/tables/partner_boxes_table.dart';
import '../../features/sync/data/tables/partner_snapshot_table.dart';

part 'app_database.g.dart';

/// Application-wide Drift database.
///
/// Register a feature's table here, run `build_runner`, then use it through a
/// DAO or directly from a datasource.
@DriftDatabase(
  tables: [
    ChallengeConfigRows,
    OwnBoxes,
    PartnerBoxes,
    PartnerSnapshots,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Bump this and add a migration in [migration] whenever a table changes.
  ///
  /// Version 1 was the template (`counter_entries`). Version 2 drops it and
  /// creates the four product tables. See `docs/data-model.md` §6.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // No prior users: the 1 -> 2 step may be destructive. Drop the
            // template table if it survived, then create the product schema.
            await m.database
                .customStatement('DROP TABLE IF EXISTS counter_entries');
            await m.createAll();
          }
        },
      );

  /// `drift_flutter` picks the right implementation per platform and stores the
  /// file under the app's documents directory.
  static QueryExecutor _openConnection() => driftDatabase(name: 'mori_db');
}
