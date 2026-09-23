import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/responsive_layout.dart';

/// A sleek, frosted-glass sticky bottom action bar designed for wizards and forms.
/// Keeps primary action within thumb reach without needing to scroll to the bottom.
class AppStickyActionBar extends StatelessWidget {
  const AppStickyActionBar({
    super.key,
    required this.onPrimaryPressed,
    required this.primaryLabel,
    this.primaryIcon = Icons.arrow_forward_rounded,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.statusText,
    this.isLoading = false,
  });

  final VoidCallback? onPrimaryPressed;
  final String primaryLabel;
  final IconData? primaryIcon;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final String? statusText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? AppColors.bgDark : Colors.white).withValues(alpha: 0.88),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.lineDark : AppColors.lineLight,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: ResponsiveContentConstraint(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  if (onSecondaryPressed != null && secondaryLabel != null) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: onSecondaryPressed,
                      child: Text(secondaryLabel!),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (statusText != null) ...[
                    Expanded(
                      child: Text(
                        statusText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : AppColors.inkSoft,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: (statusText == null && onSecondaryPressed == null) ? 1 : 0,
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          elevation: 2,
                          shadowColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: isLoading ? null : onPrimaryPressed,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    primaryLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (primaryIcon != null) ...[
                                    const SizedBox(width: 8),
                                    Icon(primaryIcon, size: 18),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
