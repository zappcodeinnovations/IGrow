import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Variants for [AppButton].
enum AppButtonVariant { primary, secondary, outline, text }

/// A design-system button with primary / secondary / outline / text variants.
///
/// Uses 16px radius, min 48dp height (prefers 54dp for rural/older users),
/// and the IGrow green color palette.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.height = 54,
    this.borderRadius = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
    final minSize = Size(isExpanded ? double.infinity : 0, height);

    Widget child = _buildChild(context);

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: minSize,
            shape: shape,
            backgroundColor: AppColors.editorialPrimary,
            foregroundColor: AppColors.editorialOnPrimary,
            disabledBackgroundColor: AppColors.editorialPrimary.withValues(alpha: 0.5),
            elevation: 0,
          ),
          child: child,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: minSize,
            shape: shape,
            backgroundColor: AppColors.editorialSecondaryFixed,
            foregroundColor: AppColors.editorialOnSecondaryFixed,
            elevation: 0,
          ),
          child: child,
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: minSize,
            shape: shape,
            side: const BorderSide(color: AppColors.editorialPrimary, width: 1.5),
            foregroundColor: AppColors.editorialPrimary,
          ),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: minSize,
            shape: shape,
            foregroundColor: AppColors.editorialSecondary,
          ),
          child: child,
        );
    }
  }

  Widget _buildChild(BuildContext context) {
    final textStyle = AppTypography.labelLarge(
      color: variant == AppButtonVariant.primary
          ? AppColors.editorialOnPrimary
          : (variant == AppButtonVariant.secondary 
              ? AppColors.editorialOnSecondaryFixed 
              : AppColors.editorialPrimary),
    );

    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(
                variant == AppButtonVariant.primary
                    ? AppColors.editorialOnPrimary
                    : AppColors.editorialSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Please wait...', style: textStyle),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: textStyle),
        ],
      );
    }

    return Text(label, style: textStyle);
  }
}
