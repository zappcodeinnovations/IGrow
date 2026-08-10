import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The signature "Canopy Gradient" used on splash, onboarding, and
/// success screens. A soft [RadialGradient] from forest-green tint
/// through the base background to warm yellow tint.
class CanopyGradient extends StatelessWidget {
  const CanopyGradient({
    super.key,
    this.child,
    this.alignment = Alignment.topCenter,
    this.radius = 1.2,
  });

  final Widget? child;
  final Alignment alignment;
  final double radius;

  /// Returns the raw [RadialGradient] for use in decorations.
  static RadialGradient gradient({
    Alignment center = Alignment.topCenter,
    double radius = 1.2,
    bool isDark = false,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: isDark
          ? const [
              Color(0xFF1D2B22), // AppColors.cardDark
              Color(0xFF14201A), // AppColors.bgDark
              Color(0xFF0D3308), // AppColors.greenDark (deep forest tint)
            ]
          : const [
              AppColors.canopyStart, // #E9F5E4
              AppColors.canopyMid,   // #F8FAF5
              AppColors.canopyEnd,   // #FFF8E1
            ],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient(center: alignment, radius: radius, isDark: isDark),
      ),
      child: child,
    );
  }
}
