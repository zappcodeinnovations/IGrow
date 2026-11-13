import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Helper utility for creating Unicode-compliant PDF themes supporting
/// English, Marathi, Hindi (Devanagari script), Indian languages, and Indian Rupee symbols (₹).
class PdfThemeHelper {
  static pw.ThemeData? _cachedTheme;

  /// Loads font theme supporting Latin, Devanagari (Hindi, Marathi),
  /// and Indian regional languages & symbols. Gracefully falls back if fonts cannot
  /// be loaded (e.g. offline).
  static Future<pw.ThemeData> getInvoiceTheme() async {
    if (_cachedTheme != null) return _cachedTheme!;

    try {
      final notoSans = await PdfGoogleFonts.notoSansRegular();
      final notoSansBold = await PdfGoogleFonts.notoSansBold();
      final devanagari = await PdfGoogleFonts.notoSansDevanagariRegular();
      final devanagariBold = await PdfGoogleFonts.notoSansDevanagariBold();
      final marathi = await PdfGoogleFonts.tiroDevanagariMarathiRegular();

      // Additional Indian scripts fallback
      final fallbackFonts = <pw.Font>[
        devanagari,
        devanagariBold,
        marathi,
      ];

      try {
        final gujarati = await PdfGoogleFonts.notoSansGujaratiRegular();
        final bengali = await PdfGoogleFonts.notoSansBengaliRegular();
        final tamil = await PdfGoogleFonts.notoSansTamilRegular();
        final telugu = await PdfGoogleFonts.notoSansTeluguRegular();
        fallbackFonts.addAll([gujarati, bengali, tamil, telugu]);
      } catch (e) {
        debugPrint('⚠️ [PdfThemeHelper] Optional Indic font loading skipped: $e');
      }

      _cachedTheme = pw.ThemeData.withFont(
        base: notoSans,
        bold: notoSansBold,
        fontFallback: fallbackFonts,
      );
      return _cachedTheme!;
    } catch (e) {
      debugPrint('⚠️ [PdfThemeHelper] Error loading Google Fonts: $e. Using base theme.');
      return pw.ThemeData.base();
    }
  }

  /// Sanitizes text for PDF rendering so that emojis, invisible zero-width characters,
  /// variation selectors, or unrenderable symbols never produce broken placeholder
  /// boxes with crosses (🗙 / .notdef glyphs).
  static String sanitizePdfText(String? input) {
    if (input == null || input.isEmpty) return '';

    // 1. Strip zero-width characters, BOM, directional marks, variation selectors, control codes
    var text = input.replaceAll(
      RegExp(
        r'[\u200B-\u200D\u200E\u200F\u202A-\u202E\u2060\uFEFF\uFE00-\uFE0F\u00AD\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]',
      ),
      '',
    );

    // 2. Strip emojis, dingbats, and miscellaneous pictographs (which lack glyphs in standard TTF fonts and cause [X] boxes)
    text = text.replaceAll(
      RegExp(
        r'[\u{1F000}-\u{1FAFF}]|'
        r'[\u{2600}-\u{27BF}]|'
        r'[\u{2300}-\u{23FF}]|'
        r'[\u{2B50}-\u{2B55}]|'
        r'[\u{203C}\u{2049}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}]|'
        r'[\u{25AA}-\u{25AB}\u{25B6}\u{25C0}\u{25FB}-\u{25FE}]',
        unicode: true,
      ),
      '',
    );

    // 3. Keep only printable Unicode characters that are supported by fonts
    final cleanRunes = <int>[];
    for (final rune in text.runes) {
      // Basic Latin & Latin-1 Supplement (ASCII, numbers, standard punctuation)
      if (rune >= 0x0020 && rune <= 0x00FF) {
        cleanRunes.add(rune);
      }
      // Devanagari (Marathi, Hindi, Sanskrit) and Devanagari Extended
      else if ((rune >= 0x0900 && rune <= 0x097F) || (rune >= 0xA8E0 && rune <= 0xA8FF)) {
        cleanRunes.add(rune);
      }
      // Indian Rupee symbol (₹)
      else if (rune == 0x20B9) {
        cleanRunes.add(rune);
      }
      // Common typography: quotes, dashes, bullets, ellipses
      else if (rune >= 0x2010 && rune <= 0x2027) {
        cleanRunes.add(rune);
      }
      // Other Indian scripts (Bengali, Gurmukhi, Gujarati, Oriya, Tamil, Telugu, Kannada, Malayalam)
      else if (rune >= 0x0980 && rune <= 0x0D7F) {
        cleanRunes.add(rune);
      }
      // Any unsupported surrogate or unmapped glyph is safely dropped to avoid [X]
    }

    // Collapse any multiple consecutive spaces and trim
    return String.fromCharCodes(cleanRunes)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
