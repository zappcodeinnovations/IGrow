import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

import '../../../core/widgets/app_card.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

/// Profile screen — shared shell with role-dependent sections.
///
/// Farmer sees: Purchased Courses, Downloads, Wishlist, Certificates
/// Instructor sees: Uploaded Courses, Followers, Achievements
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isFarmer = user?.activeRole == UserRole.farmer;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile header
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                      backgroundImage: user?.avatarUrl != null 
                        ? NetworkImage(user!.avatarUrl!) as ImageProvider
                        : null,
                      child: user?.avatarUrl == null
                          ? Text(
                              user?.fullName.isNotEmpty == true
                                  ? user!.fullName[0].toUpperCase()
                                  : 'U',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primaryGreen),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'User',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            user?.activeRole.icon ?? Icons.person,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user?.activeRole.label ?? 'User',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primaryGreen,),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Wallet Card (Farmer Only)
              if (isFarmer) ...[
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryGreen, AppColors.greenDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Wallet Balance',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.white.withValues(alpha: 0.8),
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Available',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₹2,450',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Revenue Card (Instructor Only)
              if (!isFarmer) ...[
                ref.watch(instructorStatsProvider).when(
                  data: (stats) {
                    final earnings = stats['total_earnings'] ?? '0';
                    return AppCard(
                      padding: EdgeInsets.zero,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primaryGreen, AppColors.greenDark],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Revenue',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.white.withValues(alpha: 0.8),
                                      ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Lifetime',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '₹$earnings',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
              ],

              // Role switch
              if (user != null && user.grantedRoles.length > 1)
                AppCard(
                  onTap: () async {
                    final newRole = isFarmer
                        ? UserRole.instructor
                        : UserRole.farmer;
                    await ref.read(authProvider.notifier).switchRole(newRole);
                    if (context.mounted) {
                      // Clear navigation and rebuild shell.
                      context.go('/');
                    }
                  },
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.accentOrange,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Switch to ${isFarmer ? 'Instructor' : 'Farmer'} Mode',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              'Change your active role',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft,),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.inkSoft,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Role-specific sections
              if (isFarmer) ...[
                _MenuSection(
                  title: 'Basic Info',
                  items: [
                    _MenuItem(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: user?.phone.isNotEmpty == true ? user!.phone : 'Not provided',
                    ),
                    _MenuItem(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: user?.location ?? 'Not provided',
                    ),
                    _MenuItem(
                      icon: Icons.agriculture_rounded,
                      label: 'Farming Experience',
                      value: user?.farmingExperience != null && user!.farmingExperience!.isNotEmpty
                          ? (user.farmingExperience!.toUpperCase() == 'BEGINNER'
                              ? 'Beginner'
                              : user.farmingExperience!.toUpperCase() == 'INTERMEDIATE'
                                  ? 'Intermediate'
                                  : user.farmingExperience!.toUpperCase() == 'EXPERT'
                                      ? 'Expert'
                                      : '${user.farmingExperience} years')
                          : 'Not provided',
                    ),
                    _MenuItem(
                      icon: Icons.interests_rounded,
                      label: 'Areas of Interest',
                      value: user?.areasOfInterest?.join(', ') ?? 'Not provided',
                    ),
                  ],
                ),
              ] else ...[
                _MenuSection(
                  title: 'Basic Info',
                  items: [
                    _MenuItem(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: user?.phone.isNotEmpty == true ? user!.phone : 'Not provided',
                    ),
                    _MenuItem(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: user?.location ?? 'Not provided',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MenuSection(
                  title: 'Instructor Details',
                  items: [
                    if (user?.bio != null && user!.bio!.isNotEmpty)
                      _MenuItem(
                        icon: Icons.info_rounded,
                        label: 'Bio',
                        value: user.bio,
                      ),
                    _MenuItem(
                      icon: Icons.star_rounded,
                      label: 'Expertise Tags',
                      value: user?.expertiseTags ?? 'Not provided',
                    ),
                    _MenuItem(
                      icon: Icons.work_rounded,
                      label: 'Years of Experience',
                      value: user?.yearsOfExperience?.toString() ?? 'Not provided',
                    ),
                    _MenuItem(
                      icon: Icons.grass_rounded,
                      label: 'Specialty Crops',
                      value: user?.specialtyCrops ?? 'Not provided',
                    ),
                    _MenuItem(
                      icon: Icons.link_rounded,
                      label: 'Social Link',
                      value: user?.socialLink ?? 'Not provided',
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Settings section
              _MenuSection(
                title: 'Settings',
                items: [
                  _MenuItem(
                    icon: Icons.edit_rounded, 
                    label: 'Edit Profile',
                    onTap: () {
                      context.push('/edit-profile');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.language_rounded, 
                    label: 'Language',
                    onTap: () {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.clearSnackBars();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Language settings coming soon!'),
                          duration: Duration(milliseconds: 1800),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    label: Theme.of(context).brightness == Brightness.dark ? 'Light Mode' : 'Dark Mode',
                    trailingWidget: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      onChanged: (isDark) {
                        final newTheme = isDark ? ThemeMode.dark : ThemeMode.light;
                        ref.read(themeProvider.notifier).setTheme(newTheme);
                      },
                      activeThumbColor: AppColors.primaryGreen,
                    ),
                    onTap: () {
                      final currentTheme = ref.read(themeProvider);
                      final newTheme = (currentTheme == ThemeMode.dark || Theme.of(context).brightness == Brightness.dark) 
                          ? ThemeMode.light 
                          : ThemeMode.dark;
                      ref.read(themeProvider.notifier).setTheme(newTheme);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.clearSnackBars();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Notifications settings coming soon!'),
                          duration: Duration(milliseconds: 1800),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined, 
                    label: 'Privacy',
                    onTap: () => context.push('/privacy'),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded, 
                    label: 'Help & Support',
                    onTap: () => context.push('/support'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Logout
              AppCard(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref.read(authProvider.notifier).logout();
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully.'),
                      duration: Duration(milliseconds: 1800),
                    ),
                  );
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.error,),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  InkWell(
                    onTap: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(item.label,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          if (item.value != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.value!,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primaryGreen,),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (item.trailingWidget != null)
                            item.trailingWidget!
                          else
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.inkSoft,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 70,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.lineDark
                          : AppColors.lineLight,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.trailingWidget,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailingWidget;
}
