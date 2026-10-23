import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Shows a comprehensive, Apple-compliant confirmation dialog before permanently
/// deleting the user's account and all associated data.
Future<void> showDeleteAccountConfirmationDialog(BuildContext context, WidgetRef ref) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
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
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _hasConfirmed = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(() {
      final isMatch = _confirmController.text.trim().toUpperCase() == 'DELETE';
      if (isMatch != _hasConfirmed) {
        setState(() {
          _hasConfirmed = isMatch;
        });
      }
    });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleDeleteAccount() async {
    setState(() => _isLoading = true);

    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await widget.ref.read(authProvider.notifier).deleteAccount();

      if (nav.canPop()) {
        nav.pop();
      }

      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Your account and associated data have been permanently deleted.',
          ),
          duration: Duration(milliseconds: 3000),
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
          content: Text('Account deletion error: $e'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Delete Account',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to permanently delete your account? This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDark : AppColors.bgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.lineDark : AppColors.lineLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The following will be permanently erased:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppColors.inkDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _bulletPoint('Personal profile and contact information'),
                  _bulletPoint('Course enrollments, progress & certificates'),
                  _bulletPoint('Instructor media, uploads & earnings history'),
                  _bulletPoint('All stored session tokens and credentials'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Type "DELETE" below to confirm:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              enabled: !_isLoading,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: TextStyle(
                  color: (isDark ? Colors.white38 : Colors.grey.shade400),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.lineLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5),
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
                onPressed: (!_hasConfirmed || _isLoading)
                    ? null
                    : _handleDeleteAccount,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  disabledBackgroundColor: AppColors.error.withValues(alpha: 0.35),
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
                        'Delete Account',
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

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
