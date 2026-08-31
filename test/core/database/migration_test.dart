import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDatabase schema', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('schemaVersion is 2', () {
      expect(db.schemaVersion, 2);
    });

    test('onCreate builds all four product tables, each empty and usable',
        () async {
      // Touching each table forces its creation and proves it exists.
      expect(await db.select(db.challengeConfigRows).get(), isEmpty);
      expect(await db.select(db.ownBoxes).get(), isEmpty);
      expect(await db.select(db.partnerBoxes).get(), isEmpty);
      expect(await db.select(db.partnerSnapshots).get(), isEmpty);
    });

    test('counter_entries table does not exist after a fresh create',
        () async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master "
            "WHERE type='table' AND name='counter_entries'",
          )
          .get();
      expect(rows, isEmpty);
    });

    test('the four product tables are registered in sqlite_master', () async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table'",
          )
          .get();
      final names = rows.map((r) => r.read<String>('name')).toSet();
      expect(names, containsAll(<String>{
        'challenge_config_rows',
        'own_boxes',
        'partner_boxes',
        'partner_snapshots',
      }));
    });
  });

  group('AppDatabase migration 1 -> 2', () {
    test('drops a legacy counter_entries table and creates the new schema',
        () async {
      // Simulate a v1 database: raw connection with the old template table.
      final executor = NativeDatabase.memory();
      final legacy = AppDatabase(executor);
      // Create a stand-in for the old table directly, then run the migrator
      // as if upgrading from version 1.
      await legacy.customStatement(
        'CREATE TABLE IF NOT EXISTS counter_entries '
        '(id INTEGER NOT NULL PRIMARY KEY, value INTEGER NOT NULL)',
      );
      await legacy.customStatement('INSERT INTO counter_entries VALUES (1, 7)');

      // Run the 1 -> 2 upgrade path explicitly.
      await legacy.migration.onUpgrade(
        Migrator(legacy),
        1,
        2,
      );

      // Old table is gone, new tables are present and empty.
      final tables = await legacy
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table'",
          )
          .get();
      final names = tables.map((r) => r.read<String>('name')).toSet();
      expect(names.contains('counter_entries'), isFalse);
      expect(names, containsAll(<String>{'own_boxes', 'partner_boxes'}));
      expect(await legacy.select(legacy.ownBoxes).get(), isEmpty);

      await legacy.close();
    });
  });
}
