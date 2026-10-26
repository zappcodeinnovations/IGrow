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

  // ─── Organic Nature Theme Design Tokens ─────────────────────────
  static const organicCanvasLight = Color(0xFFFAFBF8);
  static const organicHeadingGreen = Color(0xFF235730);
  static const organicOliveGreen = Color(0xFF5A6F32);
  static const organicSubtitleGreen = Color(0xFF4F634D);

  static const organicHeadingDark = Color(0xFFE8F5E5);
  static const organicOliveDark = Color(0xFF8CD848);
  static const organicSubtitleDark = Color(0xFF9EB79B);

  static const organicCardLight = Color(0xFFF5FAF6);
  static const organicCardDark = Color(0xFF19251D);
  static const organicBorderLight = Color(0xFFD6E3D4);
  static const organicBorderDark = Color(0xFF2B3E2F);
  static const organicBadgeLight = Color(0xFFE4F0E1);
  static const organicBadgeDark = Color(0xFF233527);
  static const organicIconLight = Color(0xFF5E855C);
  static const organicIconDark = Color(0xFF88C982);
  static const organicHintLight = Color(0xFF7A8F78);
  static const organicHintDark = Color(0xFF7E977D);

  static const organicActionLink = Color(0xFF337E1E);
  static const organicActionLinkDark = Color(0xFF75C31A);

  static const organicButtonGradient = [
    Color(0xFF075E26),
    Color(0xFF459C16),
  ];

  static const organicButtonGradientDark = [
    Color(0xFF1B6B2E),
    Color(0xFF4EA31C),
  ];

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

  /// Ambient green shadow for organic frosted cards.
  static List<BoxShadow> organicCardShadow({bool isDark = false}) {
    return [
      BoxShadow(
        color: isDark ? const Color(0x33000000) : const Color(0x22356B2E),
        blurRadius: 20,
        offset: const Offset(0, 7),
        spreadRadius: 0,
      ),
    ];
  }

  /// Glow shadow for primary organic action button.
  static List<BoxShadow> organicButtonShadow({bool isDark = false}) {
    return [
      BoxShadow(
        color: isDark ? const Color(0x55000000) : const Color(0x550B5722),
        blurRadius: 22,
        offset: const Offset(0, 9),
        spreadRadius: 0,
      ),
    ];
  }
}

