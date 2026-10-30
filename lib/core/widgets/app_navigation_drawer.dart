import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_role.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Editorial EdTech Drawer navigation sidebar matching Stitch design specifications
class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final fullName = (user != null && user.fullName.isNotEmpty) ? user.fullName : 'Learner';
    final email = (user != null && user.email.isNotEmpty) ? user.email : 'learner@iagrow.edu';
    final roleName = user?.activeRole == UserRole.instructor
        ? 'Verified Instructor'
        : (user?.activeRole == UserRole.admin ? 'Administrator' : 'Research Fellow');

    return Drawer(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.editorialSurface,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drawer Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'iAgrow',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : AppColors.editorialOnSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.editorialSecondary.withValues(alpha: 0.25)
                              : AppColors.editorialSecondaryFixed,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'EDTECH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark
                                ? AppColors.editorialSecondaryFixedDim
                                : AppColors.editorialOnSecondaryFixed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white70 : AppColors.editorialOnSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Drawer Menu Navigation Items ───────────────────────────
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  _buildSectionHeader(context, tr(ref, 'CURRICULUM & MEDIA'), isDark),
                  const SizedBox(height: 6),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    title: tr(ref, 'Courses'),
                    iconColor: AppColors.editorialSecondary,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.explore);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.play_circle_fill_rounded,
                    title: tr(ref, 'My Learning'),
                    iconColor: AppColors.editorialSecondary,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.farmerLearning);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.favorite_rounded,
                    title: tr(ref, 'Wishlist'),
                    iconColor: Colors.redAccent,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.wishlist);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.groups_rounded,
                    title: tr(ref, 'Community Hubs'),
                    iconColor: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.farmerCommunity);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_rounded,
                    title: tr(ref, 'My Profile'),
                    iconColor: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.farmerProfile);
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  _buildSectionHeader(context, tr(ref, 'ASSISTANCE & SUPPORT'), isDark),
                  const SizedBox(height: 6),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    title: tr(ref, 'Help & Support'),
                    iconColor: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/support');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.confirmation_number_outlined,
                    title: tr(ref, 'My Tickets'),
                    iconColor: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/support?tab=my-tickets');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.security_rounded,
                    title: tr(ref, 'Privacy Settings'),
                    iconColor: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/privacy');
                    },
                  ),
                ],
              ),
            ),

            // ── Drawer User Footer ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(RouteNames.farmerProfile);
                },
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isDark ? Colors.white24 : AppColors.editorialPrimary,
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.editorialOnSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email.isNotEmpty ? email : roleName,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white38 : AppColors.editorialOnSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: isDark ? Colors.white54 : AppColors.editorialOnSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.editorialOnSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : AppColors.editorialOnSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
