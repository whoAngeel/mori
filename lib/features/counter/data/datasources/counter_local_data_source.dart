import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_providers.dart';
import '../../../../core/error/exceptions.dart';
import '../models/counter_model.dart';

part 'counter_local_data_source.g.dart';

/// Contract for the counter's local storage.
abstract interface class CounterLocalDataSource {
  Future<CounterModel> readCounter();

  Future<CounterModel> incrementCounter();
}

/// Drift-backed implementation. Throws [CacheException] on any failure so the
/// repository can map it to a [Failure].
class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  CounterLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  static const _rowId = 1;

  Future<CounterEntry> _ensureRow() async {
    final existing = await (_db.select(_db.counterEntries)
          ..where((t) => t.id.equals(_rowId)))
        .getSingleOrNull();
    if (existing != null) return existing;

    return _db.into(_db.counterEntries).insertReturning(
          const CounterEntriesCompanion(id: Value(_rowId), value: Value(0)),
        );
  }

  @override
  Future<CounterModel> readCounter() async {
    try {
      return CounterModel.fromRow(await _ensureRow());
    } on Object catch (e) {
      throw CacheException('readCounter failed: $e');
    }
  }

  @override
  Future<CounterModel> incrementCounter() async {
    try {
      final row = await _ensureRow();
      final updated = await (_db.update(_db.counterEntries)
            ..where((t) => t.id.equals(_rowId)))
          .writeReturning(
        CounterEntriesCompanion(
          value: Value(row.value + 1),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return CounterModel.fromRow(updated.first);
    } on Object catch (e) {
      throw CacheException('incrementCounter failed: $e');
    }
  }
}

@riverpod
CounterLocalDataSource counterLocalDataSource(Ref ref) =>
    CounterLocalDataSourceImpl(ref.watch(appDatabaseProvider));
