/// The three states a box can be in on this device's own board.
///
/// Pure Dart. The `sync` feature keeps its own isomorphic `WireBoxState`; the
/// two Domain layers never import each other.
enum BoxStatus {
  /// Not drawn yet.
  free,

  /// Drawn but not paid.
  assigned,

  /// Drawn and paid.
  paid,
}
