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

  // ─── Dark Mode Surfaces (Pure Black AMOLED Theme) ───────────────
  static const bgDark = Color(0xFF000000);
  static const cardDark = Color(0xFF121212);
  static const lineDark = Color(0xFF242424);

  // ─── Semantic Colors ─────────────────────────────────────────────
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFBA1A1A);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF29B6F6);

  // ─── Editorial EdTech Palette Tokens (Stitch AI) ─────────────────
  static const editorialSurface = Color(0xFFFBF9F9);
  static const editorialSurfaceDark = Color(0xFF000000);
  static const editorialSurfaceDim = Color(0xFFDBDAD9);
  static const editorialSurfaceBright = Color(0xFFFBF9F9);
  static const editorialSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const editorialSurfaceContainerLow = Color(0xFFF5F3F3);
  static const editorialSurfaceContainerLowDark = Color(0xFF121212);
  static const surfaceContainerLowDark = Color(0xFF121212);
  static const editorialSurfaceContainer = Color(0xFFEFEDED);
  static const editorialSurfaceContainerHigh = Color(0xFFE9E8E7);
  static const surfaceContainerHighDark = Color(0xFF1E1E1E);
  static const editorialSurfaceContainerHighest = Color(0xFFE3E2E2);

  static const editorialOnSurface = Color(0xFF1B1C1C);
  static const editorialOnSurfaceVariant = Color(0xFF444748);
  static const editorialOutline = Color(0xFF747878);
  static const editorialOutlineVariant = Color(0xFFC4C7C7);

  static const editorialPrimary = Color(0xFF000000);
  static const editorialOnPrimary = Color(0xFFFFFFFF);
  static const editorialPrimaryContainer = Color(0xFF1C1B1B);
  static const editorialOnPrimaryContainer = Color(0xFF858383);

  static const editorialSecondary = Color(0xFF2E7D32); // Fresh vibrant agricultural green
  static const editorialOnSecondary = Color(0xFFFFFFFF);
  static const editorialSecondaryContainer = Color(0xFF43A047);
  static const editorialOnSecondaryContainer = Color(0xFFE8F5E9);
  static const editorialSecondaryFixed = Color(0xFFDCEFD8); // Light green background badge
  static const editorialSecondaryFixedDim = Color(0xFF81C784); // Light green accent
  static const editorialOnSecondaryFixed = Color(0xFF1B5E20);
  static const editorialOnSecondaryFixedVariant = Color(0xFF2E7D32);

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

