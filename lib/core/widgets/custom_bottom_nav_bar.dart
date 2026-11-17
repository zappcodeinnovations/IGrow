import 'dart:ui';
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

/// Ultra-Premium iOS Liquid Frosted Glass Navigation Bar (Frosted Glassmorphism).
///
/// Features:
/// - Real-time optical blur (`ImageFilter.blur(sigmaX: 28, sigmaY: 28)`).
/// - Translucent frosted glass tint with high-end specular edge highlights.
/// - Active tab highlighted with a pill glow rather than an opaque black block.
/// - Multi-layered atmospheric shadow delivering natural floating depth.
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

    // iOS Frosted Glass Tokens
    final Color glassTint = isDark
        ? const Color(0xFF162019).withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.78);

    final Color glassBorder = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.85);

    // Subtle emerald pill glow for active selection
    final Color activePillBg = isDark
        ? const Color(0xFF22C55E).withValues(alpha: 0.18)
        : const Color(0xFF1B4D2E).withValues(alpha: 0.12);

    final Color activePillBorder = isDark
        ? const Color(0xFF4ADE80).withValues(alpha: 0.35)
        : const Color(0xFF1B4D2E).withValues(alpha: 0.22);

    final Color activeColor = isDark
        ? const Color(0xFF86EFAC)
        : const Color(0xFF1B4D2E);

    final Color inactiveColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 4),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              // Deep ambient drop shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                blurRadius: 28,
                spreadRadius: -2,
                offset: const Offset(0, 10),
              ),
              // Soft green underglow
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: isDark ? 0.12 : 0.05),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: glassTint,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: glassBorder,
                    width: 1.2,
                  ),
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
                        borderRadius: BorderRadius.circular(24),
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.symmetric(
                              horizontal: isActive ? 12 : 6,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? activePillBg : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive ? activePillBorder : Colors.transparent,
                                width: 1.0,
                              ),
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
                                      scale: isActive ? 1.08 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(
                                        isActive ? (item.activeIcon ?? item.icon) : item.icon,
                                        color: isActive ? activeColor : inactiveColor,
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
                                            border: Border.all(color: Colors.white, width: 1.2),
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
                                    fontSize: isActive ? 10.5 : 9.5,
                                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                    color: isActive ? activeColor : inactiveColor,
                                    letterSpacing: 0.1,
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
          ),
        ),
      ),
    );
  }
}
