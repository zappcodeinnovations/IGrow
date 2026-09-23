import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Custom theme extension carrying IGrow-specific tokens that
/// [ThemeData] doesn't natively support (card dark, line colors, etc.).
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.cardBackground,
    required this.lineColor,
    required this.inkSoft,
    required this.greenShadow,
  });

  final Color cardBackground;
  final Color lineColor;
  final Color inkSoft;
  final List<BoxShadow> greenShadow;

  static const light = AppThemeExtension(
    cardBackground: AppColors.white,
    lineColor: AppColors.lineLight,
    inkSoft: AppColors.inkSoft,
    greenShadow: [
      BoxShadow(
        color: Color(0x262E7D32), // primaryGreen @ 0.15
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
  );

  static const dark = AppThemeExtension(
    cardBackground: AppColors.cardDark,
    lineColor: AppColors.lineDark,
    inkSoft: Color(0xB3FFFFFF), // white70
    greenShadow: [
      BoxShadow(
        color: Color(0x1A2E7D32), // primaryGreen @ 0.10
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
  );

  @override
  AppThemeExtension copyWith({
    Color? cardBackground,
    Color? lineColor,
    Color? inkSoft,
    List<BoxShadow>? greenShadow,
  }) {
    return AppThemeExtension(
      cardBackground: cardBackground ?? this.cardBackground,
      lineColor: lineColor ?? this.lineColor,
      inkSoft: inkSoft ?? this.inkSoft,
      greenShadow: greenShadow ?? this.greenShadow,
    );
  }

  @override
  AppThemeExtension lerp(covariant ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      lineColor: Color.lerp(lineColor, other.lineColor, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      greenShadow: t < 0.5 ? greenShadow : other.greenShadow,
    );
  }
}

/// Builds the full [ThemeData] for IGrow (light and dark).
class AppTheme {
  AppTheme._();

  // ─── Design Constants ────────────────────────────────────────────
  static const double cardRadius = 20;
  static const double buttonRadius = 16;
  static const double sheetRadius = 26;
  static const double chipRadius = 12;
  static const double inputRadius = 16;
  static const double minTouchTarget = 48;
  static const double preferredTouchTarget = 54;

  // ─── Light Theme ─────────────────────────────────────────────────
  static ThemeData get light {
    final textTheme = AppTypography.textTheme(isDark: false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.greenLight,
        onPrimaryContainer: AppColors.greenDark,
        secondary: AppColors.accentOrange,
        onSecondary: AppColors.white,
        secondaryContainer: Color(0xFFFFE0B2),
        onSecondaryContainer: Color(0xFFE65100),
        tertiary: AppColors.skyBlue,
        onTertiary: AppColors.white,
        surface: AppColors.bgLight,
        onSurface: AppColors.inkDark,
        surfaceContainerHighest: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.lineLight,
        outlineVariant: AppColors.lineLight,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        foregroundColor: AppColors.inkDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall(),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          minimumSize: const Size(64, preferredTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.white),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          minimumSize: const Size(64, preferredTouchTarget),
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.primaryGreen),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          textStyle: AppTypography.labelMedium(color: AppColors.primaryGreen),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F6F1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: Color(0xFFE2E8DE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: Color(0xFFE2E8DE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.bodyMedium(color: AppColors.inkSoft),
        labelStyle: AppTypography.bodyMedium(color: AppColors.inkSoft),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.canopyStart,
        selectedColor: AppColors.primaryGreen,
        labelStyle: AppTypography.labelSmall(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipRadius),
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.inkSoft,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(sheetRadius)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lineLight,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        showCloseIcon: true,
        dismissDirection: DismissDirection.horizontal,
      ),
      extensions: const [AppThemeExtension.light],
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────────────
  static ThemeData get dark {
    final textTheme = AppTypography.textTheme(isDark: true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.greenLight,
        onPrimary: AppColors.bgDark,
        primaryContainer: AppColors.greenDark,
        onPrimaryContainer: AppColors.greenLight,
        secondary: AppColors.accentOrange,
        onSecondary: AppColors.bgDark,
        secondaryContainer: Color(0xFF4E2600),
        onSecondaryContainer: Color(0xFFFFE0B2),
        tertiary: AppColors.skyBlue,
        onTertiary: AppColors.bgDark,
        surface: AppColors.bgDark,
        onSurface: AppColors.white,
        surfaceContainerHighest: AppColors.cardDark,
        error: Color(0xFFEF5350),
        onError: AppColors.bgDark,
        outline: AppColors.lineDark,
        outlineVariant: AppColors.lineDark,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenLight,
          foregroundColor: AppColors.bgDark,
          minimumSize: const Size(64, preferredTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.bgDark),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.greenLight,
          minimumSize: const Size(64, preferredTouchTarget),
          side: const BorderSide(color: AppColors.greenLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.greenLight),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.greenLight,
          textStyle: AppTypography.labelMedium(color: AppColors.greenLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF19251D),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.lineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.lineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.greenLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.bodyMedium(color: AppColors.white.withValues(alpha: 0.5)),
        labelStyle: AppTypography.bodyMedium(color: AppColors.white.withValues(alpha: 0.7)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardDark,
        selectedColor: AppColors.greenDark,
        labelStyle: AppTypography.labelSmall(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipRadius),
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgDark,
        selectedItemColor: AppColors.greenLight,
        unselectedItemColor: Color(0x80FFFFFF),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(sheetRadius)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lineDark,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        showCloseIcon: true,
        dismissDirection: DismissDirection.horizontal,
      ),
      extensions: const [AppThemeExtension.dark],
    );
  }
}
