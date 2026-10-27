import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// A reusable empty/error state widget with icon, title, subtitle, and action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// Preset for "no courses found".
  const EmptyState.noCourses({
    super.key,
    this.onAction,
  })  : icon = Icons.menu_book_rounded,
        title = 'No Courses Found',
        subtitle = 'Explore our catalog to find courses that interest you.',
        actionLabel = 'Browse Courses';

  /// Preset for "no internet".
  const EmptyState.noInternet({
    super.key,
    this.onAction,
  })  : icon = Icons.wifi_off_rounded,
        title = 'No Internet Connection',
        subtitle = 'Please check your connection and try again.',
        actionLabel = 'Retry';

  /// Preset for "no orders".
  const EmptyState.noOrders({
    super.key,
    this.onAction,
  })  : icon = Icons.shopping_bag_outlined,
        title = 'No Orders Yet',
        subtitle = 'Your order history will appear here.',
        actionLabel = null;

  /// Preset for "no posts".
  const EmptyState.noPosts({
    super.key,
    this.onAction,
  })  : icon = Icons.forum_outlined,
        title = 'No Posts Yet',
        subtitle = 'Be the first to start a discussion!',
        actionLabel = 'Create Post';

  /// Preset for "no downloads".
  const EmptyState.noDownloads({
    super.key,
    this.onAction,
  })  : icon = Icons.download_done_rounded,
        title = 'No Downloads',
        subtitle = 'Downloaded content will appear here for offline access.',
        actionLabel = null;

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.editorialSecondaryFixedDim.withValues(alpha: 0.18)
                    : AppColors.editorialSecondaryFixed.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.headlineSmall(
                color: isDark ? AppColors.white : AppColors.inkDark,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium(
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.6)
                      : AppColors.inkSoft,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isExpanded: false,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
