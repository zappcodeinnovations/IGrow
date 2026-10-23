import 'package:flutter/material.dart';

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

    // Palette tokens
    final Color dockBackground = isDark ? const Color(0xFF14241A) : Colors.white;
    final Color dockBorder = isDark ? const Color(0xFF223A2B) : const Color(0xFFE2EBE0);

    final Color activePodBg = isDark ? const Color(0xFF1E3F29) : const Color(0xFFDCFCE7);
    final Color activePodBorder = isDark ? const Color(0xFF34D399).withValues(alpha: 0.4) : const Color(0xFF86EFAC);
    final Color activeTextColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D);

    final Color inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 4),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: dockBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: dockBorder,
              width: 1.2,
            ),
            boxShadow: [
              // Contact shadow
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF1B2318)).withValues(alpha: isDark ? 0.45 : 0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              // Subtle green ambient glow
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: isDark ? 0.14 : 0.06),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
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
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isActive ? 12 : 8,
                        vertical: isActive ? 5 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? activePodBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
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
