import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mori/features/sync/data/codec/crc32.dart';

void main() {
  group('Crc32.compute against known values', () {
    test('empty input', () {
      expect(Crc32.compute(Uint8List(0)), 0x00000000);
    });

    test('"123456789" is the standard check value 0xCBF43926', () {
      final data = Uint8List.fromList(ascii.encode('123456789'));
      expect(Crc32.compute(data), 0xCBF43926);
    });

    test('"The quick brown fox jumps over the lazy dog"', () {
      final data = Uint8List.fromList(
        ascii.encode('The quick brown fox jumps over the lazy dog'),
      );
      expect(Crc32.compute(data), 0x414FA339);
    });

    test('single zero byte', () {
      expect(Crc32.compute(Uint8List.fromList([0x00])), 0xD202EF8D);
    });

    test('flipping any input bit changes the checksum', () {
      final base = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final baseCrc = Crc32.compute(base);
      for (var i = 0; i < base.length; i++) {
        for (var bit = 0; bit < 8; bit++) {
          final mutated = Uint8List.fromList(base);
          mutated[i] ^= 1 << bit;
          expect(Crc32.compute(mutated), isNot(baseCrc));
        }
      }
    });
  });
}
