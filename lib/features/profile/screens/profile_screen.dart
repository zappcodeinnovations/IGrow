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

    // Display counts as single digit (e.g. "0", "1", "2") without leading zero
    final coursesDisplay = coursesCount.toString();
    final certsDisplay = certsCount.toString();

    final email = (user?.email != null && user!.email.trim().isNotEmpty)
        ? user.email.trim()
        : 'learner@iagrow.in';

    final displayName = (user?.fullName != null && user!.fullName.trim().isNotEmpty)
        ? user.fullName.trim()
        : (user?.name != null && user!.name.trim().isNotEmpty)
            ? user.name.trim()
            : tr(ref, 'Farmer');

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFFBFBFA),
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
                } else {
                  context.go(RouteNames.farmerHome);
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
        actions: const [
          SizedBox(width: 8),
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

              // ── Action Row 2: Wishlist ──
              _buildPrototypeMenuCard(
                context: context,
                icon: Icons.favorite_rounded,
                iconColor: Colors.redAccent,
                iconBgColor: isDark ? const Color(0xFF332024) : const Color(0xFFFDE8E8),
                title: tr(ref, 'My Wishlist'),
                subtitle: tr(ref, 'Saved courses and ebooks'),
                isDark: isDark,
                onTap: () => context.push(RouteNames.wishlist),
              ),
              const SizedBox(height: 12),

              // ── Action Row 3: Order History ──
              _buildPrototypeMenuCard(
                context: context,
                icon: Icons.receipt_long_rounded,
                iconColor: const Color(0xFF1B4D2E),
                title: tr(ref, 'Order History'),
                subtitle: tr(ref, 'Past purchases, invoices and receipts'),
                isDark: isDark,
                onTap: () => context.push('/orders'),
              ),
              const SizedBox(height: 12),

              // ── Action Row 4: Settings ──
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

              // ── Action Row 5: Help & Support ──
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

              // ── Action Row 6: Log Out ──
              _buildPrototypeMenuCard(
                context: context,
                icon: Icons.replay_rounded,
                iconColor: const Color(0xFF1B4D2E),
                title: tr(ref, 'Log out'),
                subtitle: tr(ref, 'Sign out securely'),
                isDark: isDark,
                onTap: () => showLogoutConfirmationDialog(context, ref),
              ),
              const SizedBox(height: 12),

              // ── Action Row 7: Delete Account ──
              _buildPrototypeMenuCard(
                context: context,
                icon: Icons.delete_forever_rounded,
                iconColor: AppColors.error,
                iconBgColor: isDark ? const Color(0xFF351D1D) : const Color(0xFFFDE8E8),
                title: tr(ref, 'Delete Account'),
                subtitle: tr(ref, 'Permanently remove account and data'),
                isDark: isDark,
                titleColor: AppColors.error,
                onTap: () => showDeleteAccountConfirmationDialog(context, ref),
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
    Color? iconBgColor,
    required String title,
    required String subtitle,
    Color? titleColor,
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
                color: iconBgColor ?? (isDark ? const Color(0xFF243026) : const Color(0xFFE8F2EA)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: isDark && iconBgColor == null ? const Color(0xFF86EFAC) : iconColor,
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
                      color: titleColor ?? (isDark ? Colors.white : const Color(0xFF1B4D2E)),
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
  // CHANGE PASSWORD DIALOG (In-App Reset / Change Password)
  // ═════════════════════════════════════════════════════════════════════════════
  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFE8F3EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: AppColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tr(ref, 'Change Password'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Current Password
                        TextFormField(
                          controller: oldPasswordController,
                          obscureText: obscureOld,
                          decoration: InputDecoration(
                            labelText: tr(ref, 'Current Password'),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(obscureOld ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                              onPressed: () => setDialogState(() => obscureOld = !obscureOld),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return tr(ref, 'Password is required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // New Password
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: obscureNew,
                          decoration: InputDecoration(
                            labelText: tr(ref, 'New Password'),
                            prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                              onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return tr(ref, 'Password is required');
                            }
                            if (val.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Confirm Password
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirm,
                          decoration: InputDecoration(
                            labelText: tr(ref, 'Confirm Password'),
                            prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                              onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return tr(ref, 'Password is required');
                            }
                            if (val != newPasswordController.text) {
                              return tr(ref, 'Passwords don\'t match');
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, top: 4),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: Text(tr(ref, 'Cancel')),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4D2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isLoading = true);

                          final success = await ref.read(authProvider.notifier).changePassword(
                                oldPassword: oldPasswordController.text,
                                newPassword: newPasswordController.text,
                                confirmPassword: confirmPasswordController.text,
                              );

                          if (context.mounted) {
                            if (success) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr(ref, 'Password changed successfully!')),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                            } else {
                              setDialogState(() => isLoading = false);
                              final error = ref.read(authProvider).error ?? 'Failed to update password';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(tr(ref, 'Change Password')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // SETTINGS BOTTOM SHEET (Language, Dark Mode, Privacy, Notifications)
  // ═════════════════════════════════════════════════════════════════════════════
  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final themeMode = sheetRef.watch(themeProvider);
            final sheetIsDark = themeMode == ThemeMode.dark ||
                (themeMode == ThemeMode.system &&
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark);

            final activeLang = sheetRef.watch(languageProvider);
            final langDisplay = activeLang == 'hi'
                ? 'हिंदी'
                : (activeLang == 'mr' ? 'मराठी' : 'English');

            final textColor = sheetIsDark ? Colors.white : const Color(0xFF1B4D2E);
            final subtitleColor = sheetIsDark ? Colors.white60 : const Color(0xFF6B7280);
            final iconColor = sheetIsDark ? const Color(0xFF86EFAC) : const Color(0xFF1B4D2E);
            final chevronColor = sheetIsDark ? Colors.white38 : const Color(0xFF9CA3AF);

            return Container(
              decoration: BoxDecoration(
                color: sheetIsDark ? const Color(0xFF1A1C1B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
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
                            color: sheetIsDark ? Colors.white24 : Colors.grey.shade300,
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
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Language
                      ListTile(
                        leading: Icon(Icons.language_rounded, color: iconColor),
                        title: Text(
                          tr(sheetRef, 'App Language'),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          langDisplay,
                          style: TextStyle(color: subtitleColor, fontSize: 13),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _showLanguageBottomSheet(context, ref);
                        },
                      ),

                      // Dark Mode Toggle
                      ListTile(
                        leading: Icon(
                          Icons.dark_mode_rounded,
                          color: iconColor,
                        ),
                        title: Text(
                          tr(sheetRef, 'Dark Mode'),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          tr(sheetRef, 'Tap switch for dark theme'),
                          style: TextStyle(color: subtitleColor, fontSize: 13),
                        ),
                        trailing: Switch(
                          value: sheetIsDark,
                          activeThumbColor: const Color(0xFF1B4D2E),
                          onChanged: (val) {
                            final newTheme = val ? ThemeMode.dark : ThemeMode.light;
                            sheetRef.read(themeProvider.notifier).setTheme(newTheme);
                          },
                        ),
                      ),

                      // Privacy
                      ListTile(
                        leading: Icon(Icons.privacy_tip_outlined, color: iconColor),
                        title: Text(
                          tr(sheetRef, 'Privacy & Permissions'),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          context.push('/privacy');
                        },
                      ),

                      // Notifications
                      ListTile(
                        leading: Icon(Icons.notifications_outlined, color: iconColor),
                        title: Text(
                          tr(sheetRef, 'Notifications'),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          context.push(RouteNames.notifications);
                        },
                      ),

                      // Reset / Change Password
                      ListTile(
                        leading: Icon(Icons.lock_reset_rounded, color: iconColor),
                        title: Text(
                          tr(sheetRef, 'Change Password'),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          tr(sheetRef, 'Reset / Change Password'),
                          style: TextStyle(color: subtitleColor, fontSize: 13),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: chevronColor),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _showChangePasswordDialog(context, ref);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
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
                                fontSize: 20,
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
                                  fontSize: 16,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                                  fontSize: 12.5,
                                  fontWeight: isDark ? FontWeight.w500 : FontWeight.normal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4D2E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => context.push('/edit-profile'),
                      child: Text(
                        tr(ref, 'Edit Profile'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tr(ref, 'Total Revenue'),
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          tr(ref, 'View Analytics'),
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '₹${formatNum(ref, earnings)}',
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

              // Consolidated Profile & Instructor Details Card
              _buildMenuSection(
                context: context,
                ref: ref,
                title: tr(ref, 'Profile & Instructor Details'),
                isDark: isDark,
                items: [
                  _MenuItemData(
                    icon: Icons.phone_rounded,
                    label: tr(ref, 'Phone'),
                    value: user?.phone.isNotEmpty == true ? user!.phone : tr(ref, 'Not provided'),
                    showChevron: true,
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _MenuItemData(
                    icon: Icons.location_on_rounded,
                    label: tr(ref, 'Location'),
                    value: user?.location ?? tr(ref, 'Not provided'),
                    showChevron: true,
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _MenuItemData(
                    icon: Icons.info_rounded,
                    label: tr(ref, 'Bio'),
                    value: user?.bio != null && user!.bio!.isNotEmpty ? user!.bio : tr(ref, 'Not provided'),
                    showChevron: true,
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _MenuItemData(
                    icon: Icons.star_rounded,
                    label: tr(ref, 'Expertise Tags'),
                    value: user?.expertiseTags ?? tr(ref, 'Not provided'),
                    showChevron: true,
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _MenuItemData(
                    icon: Icons.work_rounded,
                    label: tr(ref, 'Years of Experience'),
                    value: user?.yearsOfExperience != null
                        ? '${user!.yearsOfExperience} ${tr(ref, 'years')}'
                        : tr(ref, 'Not provided'),
                    showChevron: true,
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _MenuItemData(
                    icon: Icons.grass_rounded,
                    label: tr(ref, 'Specialty Crops'),
                    value: user?.specialtyCrops ?? tr(ref, 'Not provided'),
                    showChevron: true,
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _MenuItemData(
                    icon: Icons.link_rounded,
                    label: tr(ref, 'Social Link'),
                    value: user?.socialLink ?? tr(ref, 'Not provided'),
                    showChevron: true,
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _MenuItemData(
                    icon: Icons.verified_user_rounded,
                    label: tr(ref, 'KYC & Bank Verification'),
                    value: user?.isKycVerified == true
                        ? tr(ref, 'Verified')
                        : (user?.isKycPending == true ? tr(ref, 'Under Review') : tr(ref, 'Incomplete')),
                    onTap: () => context.push(RouteNames.instructorKyc),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Settings Section
              _buildMenuSection(
                context: context,
                ref: ref,
                title: tr(ref, 'Settings'),
                isDark: isDark,
                items: [
                  _MenuItemData(
                    icon: Icons.language_rounded,
                    label: tr(ref, 'Language'),
                    value: ref.watch(languageProvider) == 'hi'
                        ? 'हिंदी'
                        : (ref.watch(languageProvider) == 'mr' ? 'मराठी' : 'English'),
                    onTap: () => _showLanguageBottomSheet(context, ref),
                  ),
                  _MenuItemData(
                    icon: Icons.dark_mode_rounded,
                    label: tr(ref, 'Dark Mode'),
                    trailingWidget: Switch(
                      value: isDark,
                      activeThumbColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        final newTheme = val ? ThemeMode.dark : ThemeMode.light;
                        ref.read(themeProvider.notifier).setTheme(newTheme);
                      },
                    ),
                    onTap: () {
                      final newTheme = isDark ? ThemeMode.light : ThemeMode.dark;
                      ref.read(themeProvider.notifier).setTheme(newTheme);
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.notifications_outlined,
                    label: tr(ref, 'Notifications'),
                    onTap: () => context.push(RouteNames.notifications),
                  ),
                  _MenuItemData(
                    icon: Icons.lock_reset_rounded,
                    label: tr(ref, 'Change Password'),
                    onTap: () => _showChangePasswordDialog(context, ref),
                  ),
                  _MenuItemData(
                    icon: Icons.privacy_tip_outlined,
                    label: tr(ref, 'Privacy'),
                    onTap: () => context.push('/privacy'),
                  ),
                  _MenuItemData(
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
              const SizedBox(height: 16),
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
  Widget _buildMenuSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required bool isDark,
    required List<_MenuItemData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1B4D2E),
            ),
          ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
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
                            const Icon(
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
                      color: isDark ? AppColors.lineDark : AppColors.lineLight,
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

class _MenuItemData {
  const _MenuItemData({
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
