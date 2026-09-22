import 'package:flutter_test/flutter_test.dart';

String sanitizePriceInput(String val) {
  if (val.length > 1 && val.startsWith('0') && !val.startsWith('0.')) {
    final cleaned = val.replaceFirst(RegExp(r'^0+'), '');
    return cleaned.isEmpty ? '0' : cleaned;
  }
  return val;
}

void main() {
  group('Issue 9: Price Input Leading Zero Sanitization Tests', () {
    test('entering "01" is stripped to "1"', () {
      expect(sanitizePriceInput('01'), '1');
    });

    test('entering "005" is stripped to "5"', () {
      expect(sanitizePriceInput('005'), '5');
    });

    test('entering "0" remains "0"', () {
      expect(sanitizePriceInput('0'), '0');
    });

    test('entering "1499" remains "1499"', () {
      expect(sanitizePriceInput('1499'), '1499');
    });

    test('entering "0.99" decimal remains "0.99"', () {
      expect(sanitizePriceInput('0.99'), '0.99');
    });
  });
}
