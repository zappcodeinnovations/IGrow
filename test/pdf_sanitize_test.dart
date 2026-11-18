import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/core/utils/pdf_theme_helper.dart';

void main() {
  group('PdfThemeHelper Sanitization Tests', () {
    test('Cleans Marathi text with trailing emojis and pictograms', () {
      const input = 'चंदन शेतीचे फायदे आणि लागवड 🌳';
      final output = PdfThemeHelper.sanitizePdfText(input);
      expect(output, equals('चंदन शेतीचे फायदे आणि लागवड'));
    });

    test('Cleans Marathi text with zero-width characters and variation selectors', () {
      const input = 'चंदन शेतीचे फायदे आणि लागवड \u200D\uFE0F';
      final output = PdfThemeHelper.sanitizePdfText(input);
      expect(output, equals('चंदन शेतीचे फायदे आणि लागवड'));
    });

    test('Preserves Marathi letters, matras, and numbers perfectly', () {
      const input = 'हळद शेतीचे आधुनिक तंत्रज्ञान व संपूर्ण मार्गदर्शन - बॅच १';
      final output = PdfThemeHelper.sanitizePdfText(input);
      expect(output, equals('हळद शेतीचे आधुनिक तंत्रज्ञान व संपूर्ण मार्गदर्शन - बॅच १'));
    });

    test('Preserves Indian Rupee symbol (₹) and standard punctuation', () {
      const input = 'Total Amount: ₹1499.00 (Inclusive of GST)';
      final output = PdfThemeHelper.sanitizePdfText(input);
      expect(output, equals('Total Amount: ₹1499.00 (Inclusive of GST)'));
    });

    test('Handles null and empty strings gracefully', () {
      expect(PdfThemeHelper.sanitizePdfText(null), equals(''));
      expect(PdfThemeHelper.sanitizePdfText('   '), equals(''));
    });
  });
}
