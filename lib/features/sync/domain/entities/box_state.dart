/// The three box states as they travel on the wire.
///
/// The `sync` feature keeps its own state enum instead of importing
/// `challenge`'s `BoxStatus`: the Domain layers of different features never
/// import each other. The two enums are intentionally isomorphic — the wire
/// values match `docs/qr-sync-protocol.md` §4.1.
enum WireBoxState {
  /// Not drawn. Bitmap value `0b00`.
  free,

  /// Drawn, unpaid. Bitmap value `0b01`.
  assigned,

  /// Drawn and paid. Bitmap value `0b10`.
  paid,
}
