import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../utils/app_toast.dart';
import '../../data/models/user_role.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/home_farmer/providers/student_provider.dart';
import '../../features/wishlist/providers/wishlist_provider.dart';

/// Shows a confirmation dialog before logging out across all panels.
///
/// If confirmed:
/// - Unregisters the FCM device token on the server and deletes the local FCM token.
/// - Clears local auth tokens and active user session.
/// - Shows feedback SnackBar and routes to '/login'.
///
/// If cancelled:
/// - Closes dialog with zero side effects.
Future<void> showLogoutConfirmationDialog(BuildContext context, [WidgetRef? ref]) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => const LogoutConfirmationDialog(),
  );
}

class LogoutConfirmationDialog extends ConsumerStatefulWidget {
  const LogoutConfirmationDialog({super.key, this.ref});

  final WidgetRef? ref;

  @override
  ConsumerState<LogoutConfirmationDialog> createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends ConsumerState<LogoutConfirmationDialog> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    final nav = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final activeRole = ref.read(authProvider).user?.activeRole ?? UserRole.farmer;
      await ref.read(authProvider.notifier).logout();

      // Reset and invalidate user-specific cached state across the app
      ref.invalidate(wishlistProvider);
      ref.invalidate(cartProvider);
      ref.invalidate(studentEnrollmentsProvider);
      ref.invalidate(studentCartProvider);

      if (nav.canPop()) {
        nav.pop();
      }

      if (!mounted) return;
      AppToast.show(
        context,
        'Logged out successfully.',
        severity: ToastSeverity.success,
        duration: const Duration(milliseconds: 1800),
      );

      context.go('/login?role=${activeRole.name}');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.show(
          context,
          'Logout failed: $e',
          severity: ToastSeverity.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirm Logout',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.inkDark,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Are you sure you want to log out? You will need to sign in again to access your courses and account data.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.lineLight : AppColors.inkSoft,
                  height: 1.4,
                ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDark ? AppColors.lineDark : AppColors.lineLight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark ? AppColors.white : AppColors.inkDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isLoading ? null : _handleLogout,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
