import 'package:drift/drift.dart';

/// The 365 boxes of this device's own board. Seeded whole at pairing time;
/// rows are never inserted or deleted afterwards, only their [status] changes.
///
/// Owned by the `challenge` feature. See `docs/data-model.md` §2.2.
@DataClassName('OwnBoxRow')
class OwnBoxes extends Table {
  /// `1..365`. Also the amount in MXN.
  IntColumn get day => integer()();

  /// `0` free, `1` assigned, `2` paid.
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Local only, never travels in the QR. `null` after a RESTORE.
  IntColumn get drawnAtMillis => integer().nullable()();

  /// Local only, never travels in the QR. `null` after a RESTORE.
  IntColumn get paidAtMillis => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {day};
}
