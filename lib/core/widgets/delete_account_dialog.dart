import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Shows a confirmation dialog before permanently deleting the account.
///
/// Requires the user to explicitly type 'DELETE' to confirm.
/// If confirmed:
/// - Unregisters the FCM device token on the server and deletes the local FCM token.
/// - Calls the account deletion routine and clears local auth tokens.
/// - Shows feedback SnackBar and routes to '/login'.
///
/// If cancelled:
/// - Closes dialog with zero side effects.
Future<void> showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => DeleteAccountConfirmationDialog(ref: ref),
  );
}

class DeleteAccountConfirmationDialog extends StatefulWidget {
  const DeleteAccountConfirmationDialog({super.key, required this.ref});

  final WidgetRef ref;

  @override
  State<DeleteAccountConfirmationDialog> createState() =>
      _DeleteAccountConfirmationDialogState();
}

class _DeleteAccountConfirmationDialogState
    extends State<DeleteAccountConfirmationDialog> {
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String _typedText = '';

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(() {
      setState(() {
        _typedText = _confirmController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canDelete => _typedText == 'DELETE';

  Future<void> _handleDelete() async {
    if (!_canDelete || _isLoading) return;

    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isLoading = true);

    try {
      await widget.ref.read(authProvider.notifier).deleteAccount();

      if (nav.canPop()) {
        nav.pop();
      }

      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Your account has been deleted successfully.'),
          duration: Duration(milliseconds: 2500),
          backgroundColor: AppColors.error,
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
          content: Text('Failed to delete account: $e'),
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
      content: SingleChildScrollView(
        child: Column(
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
                Icons.delete_forever_rounded,
                color: AppColors.error,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.inkDark,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'This action is permanent and cannot be undone. All your personal data, enrolled courses, and certificates will be permanently deleted.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.lineLight : AppColors.inkSoft,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Type DELETE to confirm:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.white : AppColors.inkDark,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              enabled: !_isLoading,
              style: TextStyle(
                color: isDark ? AppColors.white : AppColors.inkDark,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: TextStyle(
                  color: (isDark ? AppColors.lineLight : AppColors.inkSoft)
                      .withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: isDark
                    ? AppColors.bgDark
                    : AppColors.bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.lineDark : AppColors.lineLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.lineDark : AppColors.lineLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
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
                onPressed: (_canDelete && !_isLoading) ? _handleDelete : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  disabledBackgroundColor:
                      AppColors.error.withValues(alpha: 0.35),
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
                        'Delete',
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
