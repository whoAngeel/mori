import 'package:drift/drift.dart';

/// The 365 boxes of the partner's board: a read-only replica, replaced whole
/// from the last accepted bitmap. Holds 0 or 365 rows, never in between.
///
/// Owned by the `sync` feature. See `docs/data-model.md` §2.3.
@DataClassName('PartnerBoxRow')
class PartnerBoxes extends Table {
  /// `1..365`.
  IntColumn get day => integer()();

  /// `0` free, `1` assigned, `2` paid.
  IntColumn get status => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {day};
}
