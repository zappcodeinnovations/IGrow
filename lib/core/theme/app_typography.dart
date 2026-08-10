import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// IGrow typography system.
///
/// - **Display / Headline**: Inter (400, 700)
/// - **Body / UI**: Inter (400, 700)
class AppTypography {
  AppTypography._();

  // ─── Display / Headline ────────────────────────────────────────

  static TextStyle displayLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static TextStyle displaySmall({Color? color}) => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.3,
  );

  static TextStyle headlineLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.3,
  );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.35,
  );

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.4,
  );

  // ─── Title ───────────────────────────────────────────────────────

  static TextStyle titleLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.4,
  );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.4,
  );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.4,
  );

  // ─── Body ────────────────────────────────────────────────────────

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.inkDark,
    height: 1.5,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.inkDark,
    height: 1.5,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.inkSoft,
    height: 1.5,
  );

  // ─── Label / Button ──────────────────────────────────────────────

  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkDark,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.inkSoft,
    height: 1.4,
    letterSpacing: 0.2,
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
