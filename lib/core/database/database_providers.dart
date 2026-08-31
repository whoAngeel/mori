import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';

part 'database_providers.g.dart';

/// Single [AppDatabase] instance for the whole app lifetime.
///
/// `keepAlive: true` prevents Riverpod from disposing (and closing) the
/// connection when no widget is listening. Override this in tests with an
/// in-memory executor.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
