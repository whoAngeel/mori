import 'dart:typed_data';

/// CRC-32/IEEE 802.3 with a lazily-built lookup table.
///
/// Reversed polynomial `0xEDB88320`, initial value `0xFFFFFFFF`, final XOR
/// `0xFFFFFFFF`. Implemented by hand to avoid a dependency — see
/// `docs/qr-sync-protocol.md` §4.3.
///
/// This detects corruption, not tampering: it is not cryptography and does not
/// pretend to be.
abstract final class Crc32 {
  static Uint32List? _table;

  static Uint32List get _lookup => _table ??= _buildTable();

  static Uint32List _buildTable() {
    final table = Uint32List(256);
    for (var n = 0; n < 256; n++) {
      var c = n;
      for (var k = 0; k < 8; k++) {
        c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
      }
      table[n] = c;
    }
    return table;
  }

  /// Computes the CRC-32/IEEE checksum of [data].
  static int compute(Uint8List data) {
    final table = _lookup;
    var crc = 0xFFFFFFFF;
    for (final b in data) {
      crc = table[(crc ^ b) & 0xFF] ^ (crc >> 8);
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }
}
