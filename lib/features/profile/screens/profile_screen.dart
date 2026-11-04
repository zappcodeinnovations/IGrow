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
import '../../../core/widgets/shell_scaffold.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../../certificates/providers/certificates_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

/// Student & Farmer Profile Screen matching prototype Screen 36 ("Student Profile")
/// with clean fallbacks for Instructor view.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isFarmer = user?.activeRole == UserRole.farmer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isFarmer) {
      return _buildStudentProfileView(context, ref, user, isDark);
    } else {
      return _buildInstructorProfileView(context, ref, user, isDark);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // STUDENT / FARMER PROFILE VIEW (Screen 36)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildStudentProfileView(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    bool isDark,
  ) {
    final enrollmentsAsync = ref.watch(studentEnrollmentsProvider);
    final certsAsync = ref.watch(myCertificatesProvider);

    final coursesCount = enrollmentsAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final certsCount = certsAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    // Format numbers with 2-digit padding like in prototype ("02", "01")
    final coursesDisplay = coursesCount.toString().padLeft(2, '0');
    final certsDisplay = certsCount.toString().padLeft(2, '0');

    final email = (user?.email != null && user!.email.trim().isNotEmpty)
        ? user.email.trim()
        : 'learner@iagrow.in';

    final displayName = (user?.fullName != null && user!.fullName.trim().isNotEmpty)
        ? user.fullName.trim()
        : (user?.name != null && user!.name.trim().isNotEmpty)
            ? user.name.trim()
            : tr(ref, 'Farmer');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121413) : const Color(0xFFFBFBFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                } else if (shellScaffoldKey.currentState != null) {
                  shellScaffoldKey.currentState!.openDrawer();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.cardDark : const Color(0xFFE8EFE8),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 12,
        title: Text(
          tr(ref, 'My profile'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: isDark ? Colors.white : const Color(0xFF1B4D2E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: isDark ? Colors.white70 : const Color(0xFF1B4D2E),
            onPressed: () => _showProfileMenuSheet(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // ── Circular Avatar Badge ──
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A362D) : const Color(0xFFE2EDE4),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              user!.avatarUrl!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                size: 52,
                                color: Color(0xFF1B4D2E),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            size: 52,
                            color: Color(0xFF1B4D2E),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── User's Name ──
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                ),
              ),
              const SizedBox(height: 6),

              // ── Subtitle / Email ──
              Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // ── 2 Metric Cards: [ 02 Courses ]  [ 01 Certificates ] ──
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      number: coursesDisplay,
                      label: tr(ref, 'Courses'),
                      isDark: isDark,
                      onTap: () => context.go(RouteNames.farmerLearning),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      number: certsDisplay,
                      label: tr(ref, 'Certificates'),
                      isDark: isDark,
                      onTap: () => context.push(RouteNames.certificates),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Action Row 1: Edit Profile ──
              _buildPrototypeMenuCard(
                context: context,
                icon: Icons.person_rounded,
                iconColor: const Color(0xFF1B4D2E),
                title: tr(ref, 'Edit profile'),
                subtitle: tr(ref, 'Name, phone and email'),
                isDark: isDark,
                onTap: () => context.push('/edit-profile'),
              ),
              const SizedBox(height: 12),

              // ── Action Row 2: Settings ──
              _buildPrototypeMenuCard(
                context: context,
                icon: Icons.settings_rounded,
                iconColor: const Color(0xFF1B4D2E),
                title: tr(ref, 'Settings'),
                subtitle: tr(ref, 'Language, security and privacy'),
                isDark: isDark,
                onTap: () => _showSettingsSheet(context, ref),
              ),
              const SizedBox(height: 12),

              // ── Action Row 3: Help & Support ──
              _buildPrototypeMenuCard(
                context: context,
                icon: Icons.help_outline_rounded,
                iconColor: const Color(0xFF1B4D2E),
                title: tr(ref, 'Help & support'),
                subtitle: tr(ref, 'Frequently asked questions'),
                isDark: isDark,
                onTap: () => context.push('/support'),
              ),
              const SizedBox(height: 12),

              // ── Action Row 4: Log Out ──
              _buildPrototypeMenuCard(
                context: context,
                icon: Icons.replay_rounded,
                iconColor: const Color(0xFF1B4D2E),
                title: tr(ref, 'Log out'),
                subtitle: tr(ref, 'Sign out securely'),
                isDark: isDark,
                onTap: () => showLogoutConfirmationDialog(context, ref),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Metric Card Widget (Courses / Certificates) ──
  Widget _buildMetricCard({
    required BuildContext context,
    required String number,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.lineDark : const Color(0xFFE5ECE5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : const Color(0xFF1B4D2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Menu Card Item Widget (Screen 36 List Card) ──
  Widget _buildPrototypeMenuCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.lineDark : const Color(0xFFE5ECE5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Soft rounded square icon holder
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF243026) : const Color(0xFFE8F2EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: isDark ? const Color(0xFF86EFAC) : iconColor,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Subtle chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // SETTINGS BOTTOM SHEET (Language, Dark Mode, Privacy, Notifications)
  // ═════════════════════════════════════════════════════════════════════════════
  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? const Color(0xFF1A1C1B) : Colors.white,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final activeLang = sheetRef.watch(languageProvider);
            final langDisplay = activeLang == 'hi'
                ? 'हिंदी'
                : (activeLang == 'mr' ? 'मराठी' : 'English');

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr(sheetRef, 'Settings & Preferences'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Language
                    ListTile(
                      leading: const Icon(Icons.language_rounded, color: Color(0xFF1B4D2E)),
                      title: Text(tr(sheetRef, 'App Language')),
                      subtitle: Text(langDisplay),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _showLanguageBottomSheet(context, ref);
                      },
                    ),

                    // Dark Mode Toggle
                    ListTile(
                      leading: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: const Color(0xFF1B4D2E),
                      ),
                      title: Text(isDark ? tr(sheetRef, 'Light Mode') : tr(sheetRef, 'Dark Mode')),
                      trailing: Switch(
                        value: isDark,
                        activeThumbColor: const Color(0xFF1B4D2E),
                        onChanged: (val) {
                          final newTheme = val ? ThemeMode.dark : ThemeMode.light;
                          ref.read(themeProvider.notifier).setTheme(newTheme);
                        },
                      ),
                    ),

                    // Privacy
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF1B4D2E)),
                      title: Text(tr(sheetRef, 'Privacy & Permissions')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.push('/privacy');
                      },
                    ),

                    // Notifications
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined, color: Color(0xFF1B4D2E)),
                      title: Text(tr(sheetRef, 'Notifications')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.push(RouteNames.notifications);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // MORE ACTIONS SHEET (Wishlist, Orders, Delete Account)
  // ═════════════════════════════════════════════════════════════════════════════
  void _showProfileMenuSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? const Color(0xFF1A1C1B) : Colors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                  title: Text(tr(ref, 'My Wishlist')),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push(RouteNames.wishlist);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF1B4D2E)),
                  title: Text(tr(ref, 'Order History')),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/orders');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                  title: Text(
                    tr(ref, 'Delete Account'),
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showDeleteAccountConfirmationDialog(context, ref);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // INSTRUCTOR PROFILE VIEW (Fallback for Instructors)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildInstructorProfileView(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    bool isDark,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
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
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'Instructor',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? '',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.editorialOnSurfaceVariant,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4D2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.push('/edit-profile'),
                      child: Text(tr(ref, 'Edit Profile')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Instructor Revenue
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
                              Text(
                                tr(ref, 'Total Revenue'),
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '₹$earnings',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
              const SizedBox(height: 18),
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
                      child: const Icon(Icons.logout_rounded, color: AppColors.error),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      tr(ref, 'Logout'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HELPER: LANGUAGE BOTTOM SHEET
// ═════════════════════════════════════════════════════════════════════════════
void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
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
      return Consumer(
        builder: (context, sheetRef, _) {
          final activeLangCode = sheetRef.watch(languageProvider);
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
                        tr(sheetRef, 'Select App Language'),
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
                    final isSelected = activeLangCode.toLowerCase() == lang['code']!.toLowerCase();
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
                          await sheetRef.read(languageProvider.notifier).setLanguage(selectedCode);

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
    },
  );
}
