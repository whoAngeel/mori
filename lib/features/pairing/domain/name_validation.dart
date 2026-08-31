import 'dart:convert';

/// Validates a participant name: 1..24 UTF-8 bytes.
///
/// The bound is on encoded bytes, not characters, because that is what the QR
/// protocol stores (`docs/qr-sync-protocol.md` §5). A single emoji can eat
/// several bytes, so a short-looking name can still overflow.
abstract final class NameValidation {
  /// Maximum name length, in UTF-8 bytes.
  static const maxBytes = 24;

  /// Returns an error message in Spanish, or null when [name] is valid.
  static String? validate(String name) {
    final trimmed = name.trim();
    final bytes = utf8.encode(trimmed).length;
    if (bytes < 1) return 'Escribe un nombre';
    if (bytes > maxBytes) return 'El nombre es demasiado largo';
    return null;
  }

  /// True when [name] is within bounds.
  static bool isValid(String name) => validate(name) == null;
}
