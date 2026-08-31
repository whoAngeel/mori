import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/error/failures.dart';
import 'package:mori/core/utils/result.dart';
import 'package:mori/features/sync/data/codec/crc32.dart';
import 'package:mori/features/sync/data/codec/sync_codec.dart';
import 'package:mori/features/sync/domain/entities/box_state.dart';
import 'package:mori/features/sync/domain/entities/sync_payload.dart';

/// A valid SYNC payload as raw bytes, for targeted corruption.
Uint8List _validSyncBytes() {
  final text = SyncCodec.encodeSync(SyncSnapshot(
    pairingId: 0x0BADC0DE,
    slot: 0,
    installId: 0x1122334455667788,
    stateVersion: 0,
    startEpochDay: 20696,
    statuses: List<WireBoxState>.filled(365, WireBoxState.free),
  ));
  return Uint8List.fromList(
    base64Url.decode(text.padRight((text.length + 3) & ~3, '=')),
  );
}

String _encode(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

void _fixCrc(Uint8List bytes) {
  final bodyLen = bytes.length - 4;
  final crc = Crc32.compute(Uint8List.sublistView(bytes, 0, bodyLen));
  ByteData.sublistView(bytes).setUint32(bodyLen, crc);
}

F _failure<F extends Failure>(Result<Object?> r) => switch (r) {
      Err(:final failure) => failure as F,
      Ok() => fail('expected Err, got Ok'),
    };

void main() {
  group('validation order §7 — one test per failure type', () {
    test('check 1: non-base64url text -> MalformedPayload', () {
      expect(_failure(SyncCodec.decode('not valid base64!!!')),
          isA<MalformedPayload>());
    });

    test('check 1: too short (< 19 bytes) -> MalformedPayload', () {
      final short = _encode(List<int>.filled(10, 0x4D));
      expect(_failure(SyncCodec.decode(short)), isA<MalformedPayload>());
    });

    test('check 2: wrong magic -> MalformedPayload', () {
      final bytes = _validSyncBytes()..[0] = 0x00;
      _fixCrc(bytes);
      expect(_failure(SyncCodec.decode(_encode(bytes))),
          isA<MalformedPayload>());
    });

    test('check 3: wrong schema version -> UnsupportedSchema', () {
      final bytes = _validSyncBytes()..[1] = 0x99;
      _fixCrc(bytes);
      expect(_failure(SyncCodec.decode(_encode(bytes))),
          isA<UnsupportedSchema>());
    });

    test('check 4: unknown kind -> UnsupportedKind', () {
      final bytes = _validSyncBytes()..[2] = 0x7F;
      _fixCrc(bytes);
      expect(_failure(SyncCodec.decode(_encode(bytes))),
          isA<UnsupportedKind>());
    });

    test('check 5: wrong length for kind -> MalformedPayload', () {
      // A SYNC (kind 0x01) that is one byte too long.
      final bytes = Uint8List(119)..setRange(0, 118, _validSyncBytes());
      bytes[0] = 0x4D;
      bytes[1] = 0x01;
      bytes[2] = 0x01;
      expect(_failure(SyncCodec.decode(_encode(bytes))),
          isA<MalformedPayload>());
    });

    test('check 6: bad CRC -> ChecksumMismatch', () {
      final bytes = _validSyncBytes();
      // Flip a body byte without fixing the CRC.
      bytes[16] ^= 0xFF;
      expect(_failure(SyncCodec.decode(_encode(bytes))),
          isA<ChecksumMismatch>());
    });

    test('check 7: 0b11 bit pair -> MalformedPayload', () {
      final bytes = _validSyncBytes();
      bytes[22] |= 0xC0; // day 1 -> 0b11
      _fixCrc(bytes);
      expect(_failure(SyncCodec.decode(_encode(bytes))),
          isA<MalformedPayload>());
    });

    test('check 7: non-zero padding bits -> MalformedPayload', () {
      final bytes = _validSyncBytes();
      bytes[113] |= 0x01; // set a padding bit in the last bitmap byte
      _fixCrc(bytes);
      expect(_failure(SyncCodec.decode(_encode(bytes))),
          isA<MalformedPayload>());
    });

    test('a schema-version error is reported before a kind error', () {
      // Both schemaVersion and kind are wrong; §7 says schema (check 3) wins.
      final bytes = _validSyncBytes()
        ..[1] = 0x99
        ..[2] = 0x7F;
      _fixCrc(bytes);
      expect(_failure(SyncCodec.decode(_encode(bytes))),
          isA<UnsupportedSchema>());
    });
  });
}
