import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A shimmer-based skeleton loading placeholder.
///
/// Use for cards, lists, and detail screens while data is loading.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.margin,
  });

  /// A card-shaped skeleton.
  const SkeletonLoader.card({
    super.key,
    this.width,
    this.height = 140,
    this.borderRadius = AppTheme.cardRadius,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  /// A circular avatar skeleton.
  factory SkeletonLoader.circle({
    Key? key,
    double size = 48,
  }) {
    return SkeletonLoader(
      key: key,
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : const Color(0xFFE8EDE5),
      highlightColor: isDark ? AppColors.lineDark : const Color(0xFFF5F8F2),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
