import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Helper utility for creating Unicode-compliant PDF themes supporting
/// English, Hindi, Marathi (Devanagari script), and Indian Rupee symbols (₹).
class PdfThemeHelper {
  static pw.ThemeData? _cachedTheme;

  /// Loads font theme supporting Latin, Devanagari (Hindi, Marathi),
  /// and Indian Rupee symbols (₹). Gracefully falls back if fonts cannot
  /// be loaded (e.g. offline).
  static Future<pw.ThemeData> getInvoiceTheme() async {
    if (_cachedTheme != null) return _cachedTheme!;

    try {
      final notoSans = await PdfGoogleFonts.notoSansRegular();
      final notoSansBold = await PdfGoogleFonts.notoSansBold();
      final devanagari = await PdfGoogleFonts.notoSansDevanagariRegular();
      final devanagariBold = await PdfGoogleFonts.notoSansDevanagariBold();
      final marathi = await PdfGoogleFonts.tiroDevanagariMarathiRegular();

      _cachedTheme = pw.ThemeData.withFont(
        base: notoSans,
        bold: notoSansBold,
        fontFallback: [devanagari, devanagariBold, marathi],
      );
      return _cachedTheme!;
    } catch (e) {
      debugPrint('⚠️ [PdfThemeHelper] Error loading Google Fonts: $e. Using base theme.');
      return pw.ThemeData.base();
    }
  }
}

