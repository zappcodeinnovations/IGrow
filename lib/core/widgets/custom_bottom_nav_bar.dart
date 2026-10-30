import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Navigation item model for customizable bottom tabs.
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final VoidCallback? onTap;
  final int? badgeCount;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.onTap,
    this.badgeCount,
  });
}

/// Premium Floating Capsule Island Dock (Option 1).
///
/// Features:
/// - Floating rounded capsule geometry detached from screen edges.
/// - Active tab highlighted with a soft mint rounded capsule pod.
/// - Crisp, high-contrast slate inactive states.
/// - Smooth multi-layered drop shadow providing depth above the background.
/// - Responsive touch feedback with subtle micro-scaling.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Palette tokens (Editorial EdTech Dock)
    final Color dockBackground = isDark ? const Color(0xFF141416) : Colors.white.withValues(alpha: 0.95);
    final Color dockBorder = isDark ? const Color(0xFF2A2A2D) : const Color(0xFFE9E8E7);

    // Active pod is sculpted primary black in light mode (with crisp white icon/text) and secondary-fixed in dark mode
    final Color activePodBg = isDark ? const Color(0xFF26262B) : const Color(0xFF000000);
    final Color activePodBorder = isDark ? AppColors.editorialSecondary.withValues(alpha: 0.5) : Colors.transparent;
    final Color activeTextColor = isDark ? AppColors.editorialSecondaryFixed : Colors.white;

    final Color inactiveColor = isDark ? const Color(0xFF858383) : const Color(0xFF747878);

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 2),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: dockBackground,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: dockBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final bool isActive = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (item.onTap != null) {
                      item.onTap!();
                    } else {
                      onTap(index);
                    }
                  },
                  borderRadius: BorderRadius.circular(22),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isActive ? 12 : 8,
                        vertical: isActive ? 5 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? activePodBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                        border: isActive
                            ? Border.all(color: activePodBorder, width: 0.9)
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with optional badge
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              AnimatedScale(
                                scale: isActive ? 1.05 : 1.0,
                                duration: const Duration(milliseconds: 180),
                                child: Icon(
                                  isActive ? (item.activeIcon ?? item.icon) : item.icon,
                                  color: isActive ? activeTextColor : inactiveColor,
                                  size: isActive ? 22 : 21,
                                ),
                              ),
                              if (item.badgeCount != null && item.badgeCount! > 0)
                                Positioned(
                                  top: -4,
                                  right: -7,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: dockBackground, width: 1.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        height: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          // Text Label
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isActive ? 11 : 10,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                              color: isActive ? activeTextColor : inactiveColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
