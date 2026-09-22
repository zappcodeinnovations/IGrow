import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/canopy_gradient.dart';
import 'app_button.dart';

/// Shown when a user navigates to an unknown route.
class NotFoundScreen extends ConsumerWidget {
  const NotFoundScreen({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CanopyGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    size: 48,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Page Not Found',
                  style: AppTypography.displaySmall(
                    color: isDark ? AppColors.white : AppColors.inkDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'The page or resource you are looking for might have been moved or is currently unavailable.',
                  style: AppTypography.bodyMedium(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.7)
                        : AppColors.inkSoft,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                AppButton(
                  label: 'Back to Home',
                  onPressed: () {
                    context.go('/');
                  },
                  variant: AppButtonVariant.primary,
                  icon: Icons.home_rounded,
                ),
                if (context.canPop()) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Previous Page',
                    onPressed: () {
                      context.pop();
                    },
                    variant: AppButtonVariant.outline,
                    icon: Icons.arrow_back_rounded,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
