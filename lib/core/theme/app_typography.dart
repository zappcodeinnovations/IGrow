import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// IGrow typography system — Editorial EdTech.
///
/// - **Display / Headline**: Epilogue (600, 700)
/// - **Body / UI**: Hanken Grotesk (400, 600, 700)
class AppTypography {
  AppTypography._();

  // ─── Display / Headline (Epilogue) ────────────────────────────────

  static TextStyle displayLarge({Color? color}) => GoogleFonts.epilogue(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.15,
    letterSpacing: -0.035,
  );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.epilogue(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.2,
    letterSpacing: -0.025,
  );

  static TextStyle displaySmall({Color? color}) => GoogleFonts.epilogue(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.inkDark,
    height: 1.25,
    letterSpacing: -0.02,
  );

  static TextStyle headlineLarge({Color? color}) => GoogleFonts.epilogue(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.inkDark,
    height: 1.25,
    letterSpacing: -0.02,
  );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.epilogue(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.inkDark,
    height: 1.3,
    letterSpacing: -0.015,
  );

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.epilogue(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.inkDark,
    height: 1.35,
    letterSpacing: -0.01,
  );

  // ─── Title (Epilogue / Hanken Grotesk) ───────────────────────────

  static TextStyle titleLarge({Color? color}) => GoogleFonts.epilogue(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.3,
  );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.epilogue(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.inkDark,
    height: 1.35,
  );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.inkDark,
    height: 1.35,
  );

  // ─── Body (Hanken Grotesk) ────────────────────────────────────────

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.inkDark,
    height: 1.5,
    letterSpacing: -0.01,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.inkDark,
    height: 1.45,
    letterSpacing: 0,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.inkSoft,
    height: 1.4,
    letterSpacing: 0,
  );

  // ─── Label / Button (Hanken Grotesk) ──────────────────────────────

  static TextStyle labelLarge({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.inkDark,
    height: 1.3,
    letterSpacing: -0.005,
  );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.inkDark,
    height: 1.3,
    letterSpacing: 0.01,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkSoft,
    height: 1.2,
    letterSpacing: 0.04,
  );

  /// Builds a complete [TextTheme] for use in [ThemeData].
  static TextTheme textTheme({bool isDark = false}) {
    final defaultColor = isDark ? AppColors.white : AppColors.inkDark;
    final softColor = isDark ? AppColors.white.withValues(alpha: 0.7) : AppColors.inkSoft;
    return TextTheme(
      displayLarge: displayLarge(color: defaultColor),
      displayMedium: displayMedium(color: defaultColor),
      displaySmall: displaySmall(color: defaultColor),
      headlineLarge: headlineLarge(color: defaultColor),
      headlineMedium: headlineMedium(color: defaultColor),
      headlineSmall: headlineSmall(color: defaultColor),
      titleLarge: titleLarge(color: defaultColor),
      titleMedium: titleMedium(color: defaultColor),
      titleSmall: titleSmall(color: defaultColor),
      bodyLarge: bodyLarge(color: defaultColor),
      bodyMedium: bodyMedium(color: defaultColor),
      bodySmall: bodySmall(color: softColor),
      labelLarge: labelLarge(color: defaultColor),
      labelMedium: labelMedium(color: defaultColor),
      labelSmall: labelSmall(color: softColor),
    );
  }
}
