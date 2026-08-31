import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mori/features/pairing/domain/name_validation.dart';

void main() {
  group('NameValidation (task 4.7)', () {
    test('a normal name is valid', () {
      expect(NameValidation.validate('Andrea'), isNull);
      expect(NameValidation.isValid('Andrea'), isTrue);
    });

    test('empty or whitespace-only is rejected', () {
      expect(NameValidation.validate(''), isNotNull);
      expect(NameValidation.validate('   '), isNotNull);
    });

    test('exactly 24 bytes is accepted', () {
      final name = 'X' * 24;
      expect(utf8.encode(name).length, 24);
      expect(NameValidation.isValid(name), isTrue);
    });

    test('25 ASCII bytes is rejected', () {
      final name = 'X' * 25;
      expect(NameValidation.isValid(name), isFalse);
    });

    test('emoji count in bytes, not characters', () {
      // A purple heart is 4 UTF-8 bytes. Six of them = 24 bytes: still valid.
      const six = '💜💜💜💜💜💜';
      expect(utf8.encode(six).length, 24);
      expect(NameValidation.isValid(six), isTrue);

      // Seven = 28 bytes: rejected even though it is only 7 "characters".
      const seven = '💜💜💜💜💜💜💜';
      expect(utf8.encode(seven).length, 28);
      expect(NameValidation.isValid(seven), isFalse);
    });

    test('leading and trailing whitespace is trimmed before measuring', () {
      final name = '  ${'X' * 24}  ';
      expect(NameValidation.isValid(name), isTrue);
    });
  });
}
