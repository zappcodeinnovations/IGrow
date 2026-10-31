import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      scaffoldBackgroundColor: AppColors.editorialSurface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.editorialPrimary,
        onPrimary: AppColors.editorialOnPrimary,
        primaryContainer: AppColors.editorialPrimaryContainer,
        onPrimaryContainer: AppColors.editorialOnPrimaryContainer,
        secondary: AppColors.editorialSecondary,
        onSecondary: AppColors.editorialOnSecondary,
        secondaryContainer: AppColors.editorialSecondaryContainer,
        onSecondaryContainer: AppColors.editorialOnSecondaryContainer,
        tertiary: AppColors.editorialSecondaryFixed,
        onTertiary: AppColors.editorialOnSecondaryFixed,
        surface: AppColors.editorialSurface,
        onSurface: AppColors.editorialOnSurface,
        surfaceContainerLowest: AppColors.editorialSurfaceContainerLowest,
        surfaceContainerLow: AppColors.editorialSurfaceContainerLow,
        surfaceContainer: AppColors.editorialSurfaceContainer,
        surfaceContainerHigh: AppColors.editorialSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.editorialSurfaceContainerHighest,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.editorialOutline,
        outlineVariant: AppColors.editorialOutlineVariant,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.editorialSurface,
        foregroundColor: AppColors.editorialOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall(color: AppColors.editorialOnSurface),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.editorialSurfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.editorialPrimary,
          foregroundColor: AppColors.editorialOnPrimary,
          minimumSize: const Size(64, preferredTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.editorialOnPrimary),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.editorialPrimary,
          minimumSize: const Size(64, preferredTouchTarget),
          side: const BorderSide(color: AppColors.editorialPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.editorialPrimary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.editorialSecondary,
          textStyle: AppTypography.labelMedium(color: AppColors.editorialSecondary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.editorialSurfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.editorialSurfaceContainerHigh),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.editorialSurfaceContainerHigh),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.editorialPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.bodyMedium(color: AppColors.editorialOnSurfaceVariant),
        labelStyle: AppTypography.bodyMedium(color: AppColors.editorialOnSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.editorialSurfaceContainerLow,
        selectedColor: AppColors.editorialPrimary,
        labelStyle: AppTypography.labelSmall(color: AppColors.editorialOnSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999), // Pill-shaped as in Stitch
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.editorialSurfaceContainerLowest,
        selectedItemColor: AppColors.editorialPrimary,
        unselectedItemColor: AppColors.editorialOnSurfaceVariant,
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
        backgroundColor: AppColors.inkDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        closeIconColor: Colors.white70,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        showCloseIcon: true,
        dismissDirection: DismissDirection.horizontal,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: const [AppThemeExtension.light],
    );
  }

  // ─── Dark Theme (Pure Black AMOLED Theme) ────────────────────────
  static ThemeData get dark {
    final textTheme = AppTypography.textTheme(isDark: true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.white,
        onPrimary: AppColors.black,
        primaryContainer: Color(0xFF1E1E1E),
        onPrimaryContainer: AppColors.white,
        secondary: AppColors.editorialSecondary,
        onSecondary: AppColors.white,
        secondaryContainer: Color(0xFF1B5E20),
        onSecondaryContainer: Color(0xFFDCEFD8),
        tertiary: AppColors.editorialSecondaryFixedDim,
        onTertiary: AppColors.black,
        surface: AppColors.bgDark,
        onSurface: AppColors.white,
        surfaceContainerLowest: Color(0xFF000000),
        surfaceContainerLow: Color(0xFF0E0E0E),
        surfaceContainer: Color(0xFF141414),
        surfaceContainerHigh: Color(0xFF1C1C1C),
        surfaceContainerHighest: Color(0xFF242424),
        error: Color(0xFFEF5350),
        onError: AppColors.black,
        outline: AppColors.lineDark,
        outlineVariant: Color(0xFF333333),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall(color: AppColors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
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
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          minimumSize: const Size(64, preferredTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.black),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          minimumSize: const Size(64, preferredTouchTarget),
          side: const BorderSide(color: Color(0xFF333333), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.editorialSecondaryFixedDim,
          textStyle: AppTypography.labelMedium(color: AppColors.editorialSecondaryFixedDim),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF141414),
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
          borderSide: const BorderSide(color: AppColors.editorialSecondary, width: 1.5),
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
        selectedColor: AppColors.editorialSecondary,
        labelStyle: AppTypography.labelSmall(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipRadius),
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgDark,
        selectedItemColor: AppColors.white,
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
        backgroundColor: const Color(0xFF1E1E1E),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        closeIconColor: Colors.white70,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        showCloseIcon: true,
        dismissDirection: DismissDirection.horizontal,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: const [AppThemeExtension.dark],
    );
  }
}
