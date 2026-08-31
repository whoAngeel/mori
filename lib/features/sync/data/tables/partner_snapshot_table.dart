import 'package:drift/drift.dart';

/// Single-row table (`id == 1`) describing the last accepted partner snapshot.
/// If the row does not exist, no sync has ever happened.
///
/// Owned by the `sync` feature. See `docs/data-model.md` §2.4.
@DataClassName('PartnerSnapshotRow')
class PartnerSnapshots extends Table {
  /// Always `1`.
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// From the last accepted snapshot.
  IntColumn get stateVersion => integer()();

  /// The partner's install id, used to detect reinstalls.
  IntColumn get installId => integer()();

  /// The partner's own start date, from their payload.
  IntColumn get startEpochDay => integer()();

  /// Local clock at receive time. For display only, never for decisions.
  IntColumn get receivedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
