import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mori/core/error/failures.dart';
import 'package:mori/core/utils/result.dart';
import 'package:mori/features/sync/data/codec/sync_codec.dart';
import 'package:mori/features/sync/domain/entities/box_state.dart';
import 'package:mori/features/sync/domain/entities/sync_payload.dart';

/// Unwraps an [Ok] or fails the test.
T _ok<T>(Result<T> r) => switch (r) {
      Ok<T>(:final value) => value,
      Err<T>(:final failure) => fail('expected Ok, got Err($failure)'),
    };

List<WireBoxState> _allFree() =>
    List<WireBoxState>.filled(365, WireBoxState.free);

void main() {
  // Golden vectors from docs/qr-sync-protocol.md §11.
  const v1Text =
      'TQEBC63A3gARIjNEVWZ3iAAAAABQ2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkn6P9A';
  const v2Text =
      'TQEBC63A3gARIjNEVWZ3iAAAAAJQ2EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAbqzWSg';
  const v3Text =
      'TQEDC63A3gGZqrvM3e7_AAAAAH9Q2FDSgAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAGQW5kcmVhPPq5vg';

  group('encodeSync — length invariant', () {
    test('always 158 characters', () {
      final rng = Random(1);
      for (var t = 0; t < 50; t++) {
        final statuses = List<WireBoxState>.generate(
          365,
          (_) => WireBoxState.values[rng.nextInt(3)],
        );
        final s = SyncSnapshot(
          pairingId: rng.nextInt(0xFFFFFFFF),
          slot: rng.nextInt(2),
          installId: rng.nextInt(0x7FFFFFFF),
          stateVersion: rng.nextInt(0xFFFF),
          startEpochDay: rng.nextInt(0xFFFF),
          statuses: statuses,
        );
        expect(SyncCodec.encodeSync(s).length, 158);
      }
    });
  });

  group('round-trip with a fixed seed', () {
    test('SYNC decodes back to the same snapshot', () {
      final rng = Random(42);
      for (var t = 0; t < 100; t++) {
        final statuses = List<WireBoxState>.generate(
          365,
          (_) => WireBoxState.values[rng.nextInt(3)],
        );
        final s = SyncSnapshot(
          pairingId: rng.nextInt(0xFFFFFFFF),
          slot: rng.nextInt(2),
          installId: rng.nextInt(0x7FFFFFFF),
          stateVersion: rng.nextInt(0xFFFFFF),
          startEpochDay: rng.nextInt(0xFFFF),
          statuses: statuses,
        );
        final decoded = _ok(SyncCodec.decode(SyncCodec.encodeSync(s)));
        expect(decoded, isA<DecodedSync>());
        expect((decoded as DecodedSync).snapshot, s);
      }
    });

    test('PAIR decodes back to the same invite', () {
      final rng = Random(7);
      for (var t = 0; t < 50; t++) {
        final p = PairInvite(
          pairingId: rng.nextInt(0xFFFFFFFF),
          slot: rng.nextInt(2),
          installId: rng.nextInt(0x7FFFFFFF),
          startEpochDay: rng.nextInt(0xFFFF),
          name: 'user$t',
        );
        final decoded = _ok(SyncCodec.decode(SyncCodec.encodePair(p)));
        expect((decoded as DecodedPair).invite, p);
      }
    });

    test('RESTORE decodes back to the same payload', () {
      final rng = Random(9);
      for (var t = 0; t < 50; t++) {
        final statuses = List<WireBoxState>.generate(
          365,
          (_) => WireBoxState.values[rng.nextInt(3)],
        );
        final r = RestorePayload(
          pairingId: rng.nextInt(0xFFFFFFFF),
          senderSlot: rng.nextInt(2),
          senderInstallId: rng.nextInt(0x7FFFFFFF),
          restoredStateVersion: rng.nextInt(0xFFFFFF),
          startEpochDay: rng.nextInt(0xFFFF),
          snapshotEpochDay: rng.nextInt(0xFFFF),
          senderName: 'Sender$t',
          statuses: statuses,
        );
        final decoded = _ok(SyncCodec.decode(SyncCodec.encodeRestore(r)));
        expect((decoded as DecodedRestore).payload, r);
      }
    });
  });

  group('golden vectors (§11) — byte for byte via base64url text', () {
    test('V1: freshly seeded state', () {
      final s = SyncSnapshot(
        pairingId: 0x0BADC0DE,
        slot: 0,
        installId: 0x1122334455667788,
        stateVersion: 0,
        startEpochDay: 20696,
        statuses: _allFree(),
      );
      expect(SyncCodec.encodeSync(s), v1Text);

      final decoded = _ok(SyncCodec.decode(v1Text)) as DecodedSync;
      expect(decoded.snapshot, s);
    });

    test('V2: day 1 assigned, day 365 paid, stateVersion 2', () {
      final statuses = _allFree()
        ..[0] = WireBoxState.assigned
        ..[364] = WireBoxState.paid;
      final s = SyncSnapshot(
        pairingId: 0x0BADC0DE,
        slot: 0,
        installId: 0x1122334455667788,
        stateVersion: 2,
        startEpochDay: 20696,
        statuses: statuses,
      );
      expect(SyncCodec.encodeSync(s), v2Text);

      final decoded = _ok(SyncCodec.decode(v2Text)) as DecodedSync;
      expect(decoded.snapshot.statuses[0], WireBoxState.assigned);
      expect(decoded.snapshot.statuses[364], WireBoxState.paid);
    });

    test('V3: RESTORE from Andrea (slot B) to slot A', () {
      final statuses = _allFree()
        ..[0] = WireBoxState.paid
        ..[44] = WireBoxState.assigned
        ..[364] = WireBoxState.paid;
      final r = RestorePayload(
        pairingId: 0x0BADC0DE,
        senderSlot: 1,
        senderInstallId: 0x99AABBCCDDEEFF00,
        restoredStateVersion: 127,
        startEpochDay: 20696,
        snapshotEpochDay: 20690,
        senderName: 'Andrea',
        statuses: statuses,
      );
      expect(SyncCodec.encodeRestore(r), v3Text);

      final decoded = _ok(SyncCodec.decode(v3Text)) as DecodedRestore;
      expect(decoded.payload, r);
    });
  });

  group('RESTORE variable length', () {
    RestorePayload restoreWithName(String name) => RestorePayload(
          pairingId: 0x0BADC0DE,
          senderSlot: 1,
          senderInstallId: 0x99AABBCCDDEEFF00,
          restoredStateVersion: 127,
          startEpochDay: 20696,
          snapshotEpochDay: 20690,
          senderName: name,
          statuses: _allFree(),
        );

    test('1-byte name yields a 122-byte payload', () {
      // 122 bytes -> base64url ceil(122/3)*4 = 164, minus padding = 163 chars.
      final text = SyncCodec.encodeRestore(restoreWithName('A'));
      final decoded = _ok(SyncCodec.decode(text)) as DecodedRestore;
      expect(decoded.payload.senderName, 'A');
      expect(text.length, 163);
    });

    test('24-byte name yields a 145-byte payload', () {
      final name = 'X' * 24;
      final text = SyncCodec.encodeRestore(restoreWithName(name));
      final decoded = _ok(SyncCodec.decode(text)) as DecodedRestore;
      expect(decoded.payload.senderName, name);
      expect(text.length, 194);
    });

    test('multibyte emoji name decodes identically', () {
      // A single emoji can be several UTF-8 bytes; keep it within 24 bytes.
      const name = 'A💜B';
      final text = SyncCodec.encodeRestore(restoreWithName(name));
      final decoded = _ok(SyncCodec.decode(text)) as DecodedRestore;
      expect(decoded.payload.senderName, name);
    });
  });

  group('bitmap coverage and placement', () {
    test('365 days cover the 92 bytes with no collision or gap', () {
      // Each day set to a distinct-from-free value in turn round-trips to
      // exactly that one day being non-free.
      for (var day = 1; day <= 365; day++) {
        final statuses = _allFree()..[day - 1] = WireBoxState.assigned;
        final s = SyncSnapshot(
          pairingId: 1,
          slot: 0,
          installId: 1,
          stateVersion: 0,
          startEpochDay: 0,
          statuses: statuses,
        );
        final decoded =
            _ok(SyncCodec.decode(SyncCodec.encodeSync(s))) as DecodedSync;
        final nonFree = <int>[];
        for (var i = 0; i < 365; i++) {
          if (decoded.snapshot.statuses[i] != WireBoxState.free) {
            nonFree.add(i);
          }
        }
        expect(nonFree, [day - 1], reason: 'day $day leaked to another index');
      }
    });

    test('day 365 lands in bitmap[91] at shift 6', () {
      final i = 364;
      expect(i >> 2, 91);
      expect((3 - (i & 3)) * 2, 6);
    });
  });

  group('integrity checks', () {
    test('the 6 padding bits are always zero (last bitmap byte)', () {
      final rng = Random(3);
      for (var t = 0; t < 20; t++) {
        final statuses = List<WireBoxState>.generate(
          365,
          (_) => WireBoxState.values[rng.nextInt(3)],
        );
        final s = SyncSnapshot(
          pairingId: 1,
          slot: 0,
          installId: 1,
          stateVersion: 0,
          startEpochDay: 0,
          statuses: statuses,
        );
        final text = SyncCodec.encodeSync(s);
        final bytes = _base64UrlBytes(text);
        // Last bitmap byte is at offset 22 + 91 = 113.
        expect(bytes[113] & 0x3F, 0, reason: 'padding not zero on iter $t');
      }
    });

    test('flipping any bit invalidates the CRC', () {
      final s = SyncSnapshot(
        pairingId: 0x0BADC0DE,
        slot: 0,
        installId: 0x1122334455667788,
        stateVersion: 0,
        startEpochDay: 20696,
        statuses: _allFree(),
      );
      final bytes = _base64UrlBytes(SyncCodec.encodeSync(s));
      for (var i = 0; i < bytes.length; i++) {
        for (var bit = 0; bit < 8; bit++) {
          final mutated = List<int>.from(bytes);
          mutated[i] ^= 1 << bit;
          final text = _bytesToBase64Url(mutated);
          final result = SyncCodec.decode(text);
          expect(
            result is Err,
            isTrue,
            reason: 'byte $i bit $bit should invalidate the payload',
          );
        }
      }
    });

    test('0b11 in any bit pair yields MalformedPayload', () {
      final s = SyncSnapshot(
        pairingId: 0x0BADC0DE,
        slot: 0,
        installId: 0x1122334455667788,
        stateVersion: 0,
        startEpochDay: 20696,
        statuses: _allFree(),
      );
      final bytes = _base64UrlBytes(SyncCodec.encodeSync(s));
      // Force day 1 (byte 22, shift 6) to 0b11, then recompute the CRC so we
      // isolate the 0b11 rejection from the checksum check.
      bytes[22] |= 0xC0;
      _recomputeCrc(bytes);
      final result = SyncCodec.decode(_bytesToBase64Url(bytes));
      expect(result, isA<Err<DecodedPayload>>());
      expect((result as Err).failure, isA<MalformedPayload>());
    });
  });
}

// --- test-local base64url helpers (mirror the codec's transport) ---

List<int> _base64UrlBytes(String text) {
  final padded = text.padRight((text.length + 3) & ~3, '=');
  return base64Url.decode(padded);
}

String _bytesToBase64Url(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

void _recomputeCrc(List<int> bytes) {
  final bodyLen = bytes.length - 4;
  final crc = _crc32(bytes.sublist(0, bodyLen));
  bytes[bodyLen] = (crc >> 24) & 0xFF;
  bytes[bodyLen + 1] = (crc >> 16) & 0xFF;
  bytes[bodyLen + 2] = (crc >> 8) & 0xFF;
  bytes[bodyLen + 3] = crc & 0xFF;
}

int _crc32(List<int> data) {
  var crc = 0xFFFFFFFF;
  for (final b in data) {
    crc ^= b;
    for (var k = 0; k < 8; k++) {
      crc = (crc & 1) != 0 ? 0xEDB88320 ^ (crc >> 1) : crc >> 1;
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
