import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clean, Spotless Agricultural Canvas Background for iGrow.
///
/// Features a continuous, silky-smooth vertical gradient from a gentle
/// morning pale-mint canopy at the top to a clean, uniform luminous surface
/// across the body.
///
/// Automatically manages [SystemUiOverlayStyle] to ensure date, time, battery,
/// and system icons are always crisp, dark, and clearly visible in light mode.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // In light mode: dark icons (date, time, battery) so they never blend into light background.
      // In dark mode: white icons.
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? const Color(0xFF101913) : const Color(0xFFF7FAF5),
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlay,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : const Color(0xFFFBF9F9),
          gradient: isDark
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFBF9F9),
                    Color(0xFFFBF9F9),
                  ],
                  stops: [0.0, 0.20, 1.0],
                ),
        ),
        child: child,
      ),
    );
  }
}
