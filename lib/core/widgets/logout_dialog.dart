import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Shows a confirmation dialog before logging out across all panels.
///
/// If confirmed:
/// - Unregisters the FCM device token on the server and deletes the local FCM token.
/// - Clears local auth tokens and active user session.
/// - Shows feedback SnackBar and routes to '/login'.
///
/// If cancelled:
/// - Closes dialog with zero side effects.
Future<void> showLogoutConfirmationDialog(BuildContext context, WidgetRef ref) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => LogoutConfirmationDialog(ref: ref),
  );
}

class LogoutConfirmationDialog extends StatefulWidget {
  const LogoutConfirmationDialog({super.key, required this.ref});

  final WidgetRef ref;

  @override
  State<LogoutConfirmationDialog> createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await widget.ref.read(authProvider.notifier).logout();

      if (nav.canPop()) {
        nav.pop();
      }

      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully.'),
          duration: Duration(milliseconds: 1800),
          backgroundColor: AppColors.inkDark,
        ),
      );

      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
