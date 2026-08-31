import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/box_state.dart';
import '../../domain/entities/sync_payload.dart';
import 'crc32.dart';

/// Pure-Dart QR codec: translates bytes <-> payload structures and validates
/// integrity (checks 1..7 of `docs/qr-sync-protocol.md` §7).
///
/// It knows nothing about Drift or local configuration. Checks 8..10, which
/// need local state, live in `SyncRepositoryImpl`. That boundary is what lets
/// the codec be tested against the golden vectors with no database.
abstract final class SyncCodec {
  static const _magic = 0x4D; // 'M'
  static const _schemaVersion = 0x01;

  static const _kindSync = 0x01;
  static const _kindPair = 0x02;
  static const _kindRestore = 0x03;

  static const _boxCount = 365;
  static const _bitmapBytes = 92; // ceil(365 * 2 / 8)

  static const _syncLength = 118;
  static const _crcBytes = 4;

  // ---------------------------------------------------------------------------
  // Encoding
  // ---------------------------------------------------------------------------

  /// Encodes a SYNC payload to base64url without padding (158 chars).
  static String encodeSync(SyncSnapshot s) {
    final bytes = Uint8List(_syncLength);
    final b = ByteData.sublistView(bytes);
    b.setUint8(0, _magic);
    b.setUint8(1, _schemaVersion);
    b.setUint8(2, _kindSync);
    b.setUint32(3, s.pairingId);
    b.setUint8(7, s.slot);
    b.setUint64(8, s.installId);
    b.setUint32(16, s.stateVersion);
    b.setUint16(20, s.startEpochDay);
    _writeBitmap(bytes, 22, s.statuses);
    _appendCrc(bytes, _syncLength);
    return _toBase64Url(bytes);
  }

  /// Encodes a PAIR payload to base64url without padding.
  static String encodePair(PairInvite p) {
    final name = utf8.encode(p.name);
    final total = 23 + name.length; // 19 header + name + 4 crc
    final bytes = Uint8List(total);
    final b = ByteData.sublistView(bytes);
    b.setUint8(0, _magic);
    b.setUint8(1, _schemaVersion);
    b.setUint8(2, _kindPair);
    b.setUint32(3, p.pairingId);
    b.setUint8(7, p.slot);
    b.setUint64(8, p.installId);
    b.setUint16(16, p.startEpochDay);
    b.setUint8(18, name.length);
    bytes.setRange(19, 19 + name.length, name);
    _appendCrc(bytes, total);
    return _toBase64Url(bytes);
  }

  /// Encodes a RESTORE payload to base64url without padding.
  static String encodeRestore(RestorePayload r) {
    final name = utf8.encode(r.senderName);
    final total = 121 + name.length; // 117 header+bitmap + name + 4 crc
    final bytes = Uint8List(total);
    final b = ByteData.sublistView(bytes);
    b.setUint8(0, _magic);
    b.setUint8(1, _schemaVersion);
    b.setUint8(2, _kindRestore);
    b.setUint32(3, r.pairingId);
    b.setUint8(7, r.senderSlot);
    b.setUint64(8, r.senderInstallId);
    b.setUint32(16, r.restoredStateVersion);
    b.setUint16(20, r.startEpochDay);
    b.setUint16(22, r.snapshotEpochDay);
    _writeBitmap(bytes, 24, r.statuses);
    b.setUint8(116, name.length);
    bytes.setRange(117, 117 + name.length, name);
    _appendCrc(bytes, total);
    return _toBase64Url(bytes);
  }

  // ---------------------------------------------------------------------------
  // Decoding
  // ---------------------------------------------------------------------------

  /// Decodes and validates a scanned payload.
  ///
  /// Runs checks 1..7 of §7 in order: the first failure wins. Checks 8..10
  /// need local state and are not done here.
  static Result<DecodedPayload> decode(String text) {
    // Check 1: decodes as base64url and length >= 19.
    final Uint8List bytes;
    try {
      bytes = _fromBase64Url(text.trim());
    } on FormatException {
      return const Err(MalformedPayload());
    }
    if (bytes.length < 19) return const Err(MalformedPayload());

    final b = ByteData.sublistView(bytes);

    // Check 2: magic.
    if (b.getUint8(0) != _magic) return const Err(MalformedPayload());

    // Check 3: schema version.
    if (b.getUint8(1) != _schemaVersion) return const Err(UnsupportedSchema());

    // Check 4: kind is one of the three known values.
    final kind = b.getUint8(2);
    if (kind != _kindSync && kind != _kindPair && kind != _kindRestore) {
      return const Err(UnsupportedKind());
    }

    // Check 5: total length matches the kind. For variable-length kinds the
    // length is validated against the declared name length.
    switch (kind) {
      case _kindSync:
        if (bytes.length != _syncLength) return const Err(MalformedPayload());
      case _kindPair:
        if (bytes.length < 20) return const Err(MalformedPayload());
        final nameLen = b.getUint8(18);
        if (nameLen < 1 || nameLen > 24) return const Err(MalformedPayload());
        if (bytes.length != 23 + nameLen) return const Err(MalformedPayload());
      case _kindRestore:
        // RESTORE is variable length: validate length only after reading
        // senderNameLen at offset 116.
        if (bytes.length < 117) return const Err(MalformedPayload());
        final nameLen = b.getUint8(116);
        if (nameLen < 1 || nameLen > 24) return const Err(MalformedPayload());
        if (bytes.length != 121 + nameLen) return const Err(MalformedPayload());
    }

    // Check 6: CRC over bytes 0..(len-5).
    final bodyLen = bytes.length - _crcBytes;
    final expectedCrc = b.getUint32(bodyLen);
    final actualCrc = Crc32.compute(Uint8List.sublistView(bytes, 0, bodyLen));
    if (actualCrc != expectedCrc) return const Err(ChecksumMismatch());

    // Check 7 (bitmap kinds only): no 0b11 pair, padding is zero.
    switch (kind) {
      case _kindSync:
        return _decodeSyncBody(b, bytes);
      case _kindPair:
        return _decodePairBody(b, bytes);
      case _kindRestore:
        return _decodeRestoreBody(b, bytes);
    }
    return const Err(MalformedPayload());
  }

  static Result<DecodedPayload> _decodeSyncBody(ByteData b, Uint8List bytes) {
    final statuses = _readBitmap(bytes, 22);
    if (statuses == null) return const Err(MalformedPayload());
    return Ok(DecodedSync(SyncSnapshot(
      pairingId: b.getUint32(3),
      slot: b.getUint8(7),
      installId: b.getUint64(8),
      stateVersion: b.getUint32(16),
      startEpochDay: b.getUint16(20),
      statuses: statuses,
    )));
  }

  static Result<DecodedPayload> _decodePairBody(ByteData b, Uint8List bytes) {
    final nameLen = b.getUint8(18);
    final name = utf8.decode(bytes.sublist(19, 19 + nameLen));
    return Ok(DecodedPair(PairInvite(
      pairingId: b.getUint32(3),
      slot: b.getUint8(7),
      installId: b.getUint64(8),
      startEpochDay: b.getUint16(16),
      name: name,
    )));
  }

  static Result<DecodedPayload> _decodeRestoreBody(
    ByteData b,
    Uint8List bytes,
  ) {
    final statuses = _readBitmap(bytes, 24);
    if (statuses == null) return const Err(MalformedPayload());
    final nameLen = b.getUint8(116);
    final name = utf8.decode(bytes.sublist(117, 117 + nameLen));
    return Ok(DecodedRestore(RestorePayload(
      pairingId: b.getUint32(3),
      senderSlot: b.getUint8(7),
      senderInstallId: b.getUint64(8),
      restoredStateVersion: b.getUint32(16),
      startEpochDay: b.getUint16(20),
      snapshotEpochDay: b.getUint16(22),
      senderName: name,
      statuses: statuses,
    )));
  }

  // ---------------------------------------------------------------------------
  // Bitmap
  // ---------------------------------------------------------------------------

  /// Packs 365 box states into 92 bytes starting at [offset], MSB first.
  static void _writeBitmap(
    Uint8List bytes,
    int offset,
    List<WireBoxState> statuses,
  ) {
    assert(statuses.length == _boxCount, 'bitmap needs exactly 365 states');
    for (var i = 0; i < _boxCount; i++) {
      final byteIndex = offset + (i >> 2);
      final shift = (3 - (i & 3)) * 2;
      bytes[byteIndex] |= _wireValue(statuses[i]) << shift;
    }
    // The trailing 6 bits of the last byte are padding and stay zero.
  }

  /// Reads 92 bytes at [offset] back into 365 states, or `null` if any pair is
  /// `0b11` or the trailing padding is non-zero (check 7).
  static List<WireBoxState>? _readBitmap(Uint8List bytes, int offset) {
    final statuses = List<WireBoxState>.filled(_boxCount, WireBoxState.free);
    for (var i = 0; i < _boxCount; i++) {
      final byteIndex = offset + (i >> 2);
      final shift = (3 - (i & 3)) * 2;
      final value = (bytes[byteIndex] >> shift) & 0x03;
      final state = _wireState(value);
      if (state == null) return null; // 0b11 reserved
      statuses[i] = state;
    }
    // Padding: the last 6 bits (days 366..368) of byte offset+91 must be zero.
    final lastByte = bytes[offset + _bitmapBytes - 1];
    if ((lastByte & 0x3F) != 0) return null;
    return statuses;
  }

  static int _wireValue(WireBoxState s) => switch (s) {
        WireBoxState.free => 0x00,
        WireBoxState.assigned => 0x01,
        WireBoxState.paid => 0x02,
      };

  static WireBoxState? _wireState(int value) => switch (value) {
        0x00 => WireBoxState.free,
        0x01 => WireBoxState.assigned,
        0x02 => WireBoxState.paid,
        _ => null, // 0b11
      };

  // ---------------------------------------------------------------------------
  // Transport & CRC helpers
  // ---------------------------------------------------------------------------

  static void _appendCrc(Uint8List bytes, int total) {
    final bodyLen = total - _crcBytes;
    final crc = Crc32.compute(Uint8List.sublistView(bytes, 0, bodyLen));
    ByteData.sublistView(bytes).setUint32(bodyLen, crc);
  }

  static String _toBase64Url(Uint8List bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  static Uint8List _fromBase64Url(String text) =>
      base64Url.decode(text.padRight((text.length + 3) & ~3, '='));
}
