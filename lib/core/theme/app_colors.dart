import 'package:flutter/material.dart';

/// IGrow design system color tokens.
///
/// Light-mode palette is agriculture-inspired (greens, earth tones, sky).
/// Dark-mode surface tokens provide a deep forest-green dark theme.
class AppColors {
  AppColors._();

  // ─── Primary Greens ──────────────────────────────────────────────
  static const primaryGreen = Color(0xFF4B9C0A); // Leaf green from logo
  static const greenDark = Color(0xFF0D3308);    // Dark green text from logo
  static const greenLight = Color(0xFF75C31A);

  // ─── Accents ─────────────────────────────────────────────────────
  static const signalYellow = Color(0xFFFFC107);
  static const accentOrange = Color(0xFFF59500); // Golden orange from sun logo
  static const earthBrown = Color(0xFF795548);
  static const skyBlue = Color(0xFF42A5F5);

  // ─── Light Mode Surfaces ─────────────────────────────────────────
  static const bgLight = Color(0xFFF8FAF5);
  static const inkDark = Color(0xFF1B2318);
  static const inkSoft = Color(0xFF5B6B57);
  static const lineLight = Color(0xFFE4EBE0);

  // ─── Dark Mode Surfaces ──────────────────────────────────────────
  static const bgDark = Color(0xFF14201A);
  static const cardDark = Color(0xFF1D2B22);
  static const lineDark = Color(0xFF2B3B30);

  // ─── Semantic Colors ─────────────────────────────────────────────
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF29B6F6);

  // ─── Canopy Gradient Stops ───────────────────────────────────────
  static const canopyStart = Color(0xFFE9F5E4);
  static const canopyMid = Color(0xFFF8FAF5);
  static const canopyEnd = Color(0xFFFFF1D6);

  // ─── Utility ─────────────────────────────────────────────────────
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);

  /// Green-tinted shadow used instead of default grey elevation.
  static List<BoxShadow> greenShadow({
    double blurRadius = 24,
    Offset offset = const Offset(0, 10),
    double opacity = 0.15,
  }) {
    return [
      BoxShadow(
        color: primaryGreen.withValues(alpha: opacity),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }
}
