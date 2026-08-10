import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom navigation shell for the **Farmer / Student** role.
///
/// Tabs: Home · Explore · Community · Profile
/// (No center FAB — that's instructor-only)
class FarmerShell extends StatelessWidget {
  const FarmerShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => onTabSelected(0),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.explore_rounded,
                  label: 'Explore',
                  isSelected: currentIndex == 1,
                  onTap: () => onTabSelected(1),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.forum_rounded,
                  label: 'Community',
                  isSelected: currentIndex == 2,
                  onTap: () => onTabSelected(2),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
