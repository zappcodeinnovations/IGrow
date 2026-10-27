import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom navigation shell for the **Instructor** role.
///
/// Tabs: Home · Community · [Upload FAB] · Analytics · Profile
/// The center tab slot is a raised FAB for the "Upload Course" flow.
class InstructorShell extends ConsumerWidget {
  const InstructorShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onUploadPressed,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onUploadPressed;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDark : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.08 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: tr(ref, 'Home'),
                  isSelected: currentIndex == 0,
                  onTap: () => onTabSelected(0),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.forum_rounded,
                  label: tr(ref, 'Community'),
                  isSelected: currentIndex == 1,
                  onTap: () => onTabSelected(1),
                  isDark: isDark,
                ),
                // Center FAB
                _UploadFab(
                  onTap: onUploadPressed,
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.analytics_rounded,
                  label: tr(ref, 'Analytics'),
                  isSelected: currentIndex == 2,
                  onTap: () => onTabSelected(2),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: tr(ref, 'Profile'),
                  isSelected: currentIndex == 3,
                  onTap: () => onTabSelected(3),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadFab extends StatelessWidget {
  const _UploadFab({
    required this.onTap,
    required this.isDark,
  });

  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryGreen, AppColors.greenDark],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final selectedColor = isDark ? AppColors.greenLight : AppColors.primaryGreen;
    final unselectedColor = isDark
        ? AppColors.white.withValues(alpha: 0.45)
        : AppColors.inkSoft;
    final color = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: (isDark ? AppColors.greenDark : AppColors.primaryGreen)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall(color: color).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
