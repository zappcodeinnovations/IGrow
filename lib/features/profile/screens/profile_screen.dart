import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/delete_account_dialog.dart';
import '../../../core/widgets/logout_dialog.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile header (Editorial EdTech Monogram + Verified Identity Card)
              AppCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Monogram Avatar with Verified Badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: AppColors.editorialPrimary,
                                    backgroundImage: user?.avatarUrl != null 
                                      ? NetworkImage(user!.avatarUrl!) as ImageProvider
                                      : null,
                                    child: user?.avatarUrl == null
                                        ? Text(
                                            user?.fullName.isNotEmpty == true
                                                ? user!.fullName[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.editorialSecondary,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user?.fullName ?? 'User',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified_rounded,
                                          size: 16,
                                          color: AppColors.editorialSecondary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user?.email ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.editorialOnSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF282830) : AppColors.editorialSurfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            user?.activeRole.icon ?? Icons.person,
                                            size: 13,
                                            color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              user?.activeRole.label ?? 'User',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Edit Pill
                        InkWell(
                          onTap: () => context.push('/edit-profile'),
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : AppColors.editorialPrimary,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 14,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tr(ref, 'Edit Profile'),
                                  style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Quick Metrics Counter (Minimalist Triplet)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E22) : AppColors.editorialSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '3',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ENROLLED',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.editorialOnSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: isDark ? const Color(0xFF333338) : AppColors.editorialSurfaceContainerHigh,
                          ),
                          Column(
                            children: [
                              Text(
                                '12h',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.editorialSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'LAB HOURS',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.editorialOnSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: isDark ? const Color(0xFF333338) : AppColors.editorialSurfaceContainerHigh,
                          ),
                          Column(
                            children: [
                              Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'CERTIFICATES',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.editorialOnSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Revenue Card (Instructor Only)
              if (!isFarmer) ...[
                ref.watch(instructorStatsProvider).when(
                  data: (stats) {
                    final rawEarnings = stats['total_earnings'];
                    final earningsDouble = double.tryParse(rawEarnings?.toString() ?? '0') ?? 0.0;
                    final earnings = earningsDouble.toStringAsFixed(2);
                    return AppCard(
                      onTap: () => context.push(RouteNames.instructorAnalytics),
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
                                  tr(ref, 'Total Revenue'),
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        tr(ref, 'View Analytics'),
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.white),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.white),
                                    ],
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

              // Role switch card (Temporarily hidden/commented out from UI as requested)
              /*
              if (user != null) ...[
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
                              isFarmer ? 'Switch to Instructor Mode' : 'Switch to Farmer Mode',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              isFarmer
                                  ? 'Teach, manage students & upload courses'
                                  : 'Explore & learn agriculture courses',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.inkSoft,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              */

              // Role-specific sections
              if (isFarmer) ...[
                _MenuSection(
                  title: tr(ref, 'Basic Info'),
                  items: [
                    _MenuItem(
                      icon: Icons.phone_rounded,
                      label: tr(ref, 'Phone'),
                      value: user?.phone.isNotEmpty == true ? user!.phone : tr(ref, 'Not provided'),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.location_on_rounded,
                      label: tr(ref, 'Location'),
                      value: user?.location ?? tr(ref, 'Not provided'),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.agriculture_rounded,
                      label: tr(ref, 'Farming Experience'),
                      value: user?.farmingExperience != null && user!.farmingExperience!.isNotEmpty
                          ? (user.farmingExperience!.toUpperCase() == 'BEGINNER'
                              ? tr(ref, 'Beginner')
                              : user.farmingExperience!.toUpperCase() == 'INTERMEDIATE'
                                  ? tr(ref, 'Intermediate')
                                  : user.farmingExperience!.toUpperCase() == 'EXPERT'
                                      ? tr(ref, 'Expert')
                                      : '${user.farmingExperience} ${tr(ref, 'years')}')
                          : tr(ref, 'Not provided'),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.interests_rounded,
                      label: tr(ref, 'Areas of Interest'),
                      value: user?.areasOfInterest?.join(', ') ?? tr(ref, 'Not provided'),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MenuSection(
                  title: tr(ref, 'My Learning & Activity'),
                  items: [
                    _MenuItem(
                      icon: Icons.school_rounded,
                      label: tr(ref, 'My Enrolled Courses'),
                      onTap: () {
                        context.go(RouteNames.farmerLearning);
                      },
                    ),
                    _MenuItem(
                      icon: Icons.favorite_rounded,
                      label: tr(ref, 'My Wishlist'),
                      onTap: () {
                        context.push(RouteNames.wishlist);
                      },
                    ),
                    _MenuItem(
                      icon: Icons.receipt_long_rounded,
                      label: tr(ref, 'Order History'),
                      onTap: () {
                        context.push('/orders');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.workspace_premium_rounded,
                      label: tr(ref, 'My Certificates'),
                      onTap: () {
                        context.push(RouteNames.certificates);
                      },
                    ),
                  ],
                ),
              ] else ...[
                _MenuSection(
                  title: tr(ref, 'Basic Info'),
                  items: [
                    _MenuItem(
                      icon: Icons.phone_rounded,
                      label: tr(ref, 'Phone'),
                      value: user?.phone.isNotEmpty == true ? user!.phone : tr(ref, 'Not provided'),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.location_on_rounded,
                      label: tr(ref, 'Location'),
                      value: user?.location ?? tr(ref, 'Not provided'),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MenuSection(
                  title: tr(ref, 'Instructor Details'),
                  items: [
                    if (user?.bio != null && user!.bio!.isNotEmpty)
                      _MenuItem(
                        icon: Icons.info_rounded,
                        label: tr(ref, 'Bio'),
                        value: user.bio,
                        showChevron: false,
                        onTap: () => _showComingSoon(context, ref),
                      ),
                    _MenuItem(
                      icon: Icons.star_rounded,
                      label: tr(ref, 'Expertise Tags'),
                      value: user?.expertiseTags ?? tr(ref, 'Not provided'),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.work_rounded,
                      label: tr(ref, 'Years of Experience'),
                      value: user?.yearsOfExperience != null ? '${user!.yearsOfExperience} ${tr(ref, 'years')}' : (user?.yearsOfExperience?.toString() ?? tr(ref, 'Not provided')),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.grass_rounded,
                      label: tr(ref, 'Specialty Crops'),
                      value: user?.specialtyCrops ?? tr(ref, 'Not provided'),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.link_rounded,
                      label: tr(ref, 'Social Link'),
                      value: user?.socialLink ?? tr(ref, 'Not provided'),
                      showChevron: false,
                      onTap: () => _showComingSoon(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MenuSection(
                  title: tr(ref, 'Verification & Payouts'),
                  items: [
                    _MenuItem(
                      icon: Icons.verified_user_rounded,
                      label: tr(ref, 'KYC & Bank Verification'),
                      value: user?.isKycVerified == true
                          ? tr(ref, 'Verified')
                          : (user?.isKycPending == true ? tr(ref, 'Under Review') : tr(ref, 'Incomplete')),
                      onTap: () {
                        context.push(RouteNames.instructorKyc);
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Settings section
              _MenuSection(
                title: tr(ref, 'Settings'),
                items: [

                  _MenuItem(
                    icon: Icons.language_rounded, 
                    label: tr(ref, 'Language'),
                    onTap: () => _showLanguageBottomSheet(context, ref),
                  ),
                  _MenuItem(
                    icon: Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    label: Theme.of(context).brightness == Brightness.dark ? tr(ref, 'Light Mode') : tr(ref, 'Dark Mode'),
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
                    label: tr(ref, 'Notifications'),
                    onTap: () => context.push(RouteNames.notifications),
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined, 
                    label: tr(ref, 'Privacy'),
                    onTap: () => context.push('/privacy'),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded, 
                    label: tr(ref, 'Help & Support'),
                    onTap: () => context.push('/support'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Danger Zone: Delete Account
              AppCard(
                onTap: () => showDeleteAccountConfirmationDialog(context, ref),
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
                        Icons.delete_forever_rounded,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr(ref, 'Delete Account'),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr(ref, 'Permanently remove account and data'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkSoft,
                                  fontSize: 11.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Logout
              AppCard(
                onTap: () => showLogoutConfirmationDialog(context, ref),
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
                      tr(ref, 'Logout'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF222228) : AppColors.editorialSurfaceContainerLow,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Icon(
                              item.icon,
                              size: 19,
                              color: isDark ? Colors.white : AppColors.editorialOnSurface,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13.5,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                if (item.value != null)
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.editorialSecondary.withValues(alpha: 0.2)
                                              : AppColors.editorialSecondaryFixed,
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: Text(
                                          item.value!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: isDark
                                                    ? AppColors.editorialSecondaryFixedDim
                                                    : AppColors.editorialOnSecondaryFixed,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (item.showChevron || item.trailingWidget != null)
                            const SizedBox(width: 8),
                          if (item.trailingWidget != null)
                            item.trailingWidget!
                          else if (item.showChevron)
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.inkSoft,
                              size: 20,
                            )
                          else
                            const SizedBox.shrink(),
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
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailingWidget;
  final bool showChevron;
}

void _showComingSoon(BuildContext context, WidgetRef ref) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(tr(ref, 'Feature coming soon')),
      duration: const Duration(milliseconds: 1800),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
  final currentLangCode = ref.read(languageProvider);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final languages = [
    {'name': 'English', 'code': 'en', 'displayCode': 'EN', 'native': 'English'},
    {'name': 'Hindi', 'code': 'hi', 'displayCode': 'HI', 'native': 'हिंदी'},
    {'name': 'Marathi', 'code': 'mr', 'displayCode': 'MR', 'native': 'मराठी'},
  ];

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: isDark ? AppColors.bgDark : Colors.white,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr(ref, 'Select App Language'),
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...languages.map((lang) {
                final isSelected = currentLangCode.toLowerCase() == lang['code']!.toLowerCase();
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen.withValues(alpha: 0.1)
                        : (isDark ? AppColors.cardDark : AppColors.bgLight),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppColors.primaryGreen
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      foregroundColor: isSelected ? Colors.white : AppColors.inkDark,
                      radius: 18,
                      child: Text(
                        lang['displayCode']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.inkDark),
                        ),
                      ),
                    ),
                    title: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      lang['native']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : AppColors.inkSoft,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen)
                        : null,
                    onTap: () async {
                      final selectedCode = lang['code']!;
                      await ref.read(languageProvider.notifier).setLanguage(selectedCode);

                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                      if (context.mounted) {
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Language set to ${lang['name']} (${lang['native']})'),
                            backgroundColor: AppColors.primaryGreen,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
