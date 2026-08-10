import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/canopy_gradient.dart';
import 'app_button.dart';

/// Shown when a user navigates to a role-restricted route.
///
/// For example, a farmer deep-linking to `/instructor/upload` sees this
/// screen with a friendly message to switch roles.
class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    color: AppColors.accentOrange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Access Restricted',
                  style: AppTypography.displaySmall(
                    color: isDark ? AppColors.white : AppColors.inkDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'This section is not available for your current role. '
                  'Switch your role from Profile settings to access this feature.',
                  style: AppTypography.bodyMedium(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.7)
                        : AppColors.inkSoft,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AppButton(
                  label: 'Go Back',
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  variant: AppButtonVariant.primary,
                  icon: Icons.arrow_back_rounded,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Go to Home',
                  onPressed: () {
                    // Navigate to root which will redirect to correct shell
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  variant: AppButtonVariant.outline,
                  icon: Icons.home_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
