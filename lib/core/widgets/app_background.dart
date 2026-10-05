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
      systemNavigationBarColor: isDark ? const Color(0xFF0F1B14) : Colors.white,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlay,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF0F1B14),
                    Color(0xFF14201A),
                    Color(0xFF101913),
                  ]
                : const [
                    Color(0xFFEAF4E7), // Gentle pale-mint canopy at very top
                    Color(0xFFF5F8F3), // Smooth gradual transition
                    Color(0xFFF7FAF5), // Spotless, uniform clean surface
                  ],
            stops: const [0.0, 0.20, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}
