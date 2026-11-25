import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import 'quick_auth_dialog.dart';

/// A clean, simple, and friendly popup dialog asking the user to log in
/// to access e-books or courses.
class RequireLoginDialog extends ConsumerWidget {
  final String? message;
  final String? title;

  const RequireLoginDialog({
    super.key,
    this.title,
    this.message,
  });

  /// Displays the dialog. If the user taps "Log In", it presents [QuickAuthDialog]
  /// and returns true if authentication succeeded.
  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final shouldProceedToLogin = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => RequireLoginDialog(
        title: title,
        message: message,
      ),
    );

    if (shouldProceedToLogin == true && context.mounted) {
      return await QuickAuthDialog.show(context);
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primaryGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title ?? tr(ref, 'Login Required'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.inkDark,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            message ??
                tr(
                  ref,
                  'You have to log in to access e-books and courses. Please log in or sign up to continue.',
                ),
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
                onPressed: () => Navigator.of(context).pop(false),
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
                  tr(ref, 'Cancel'),
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
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  tr(ref, 'Log In'),
                  style: const TextStyle(
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
