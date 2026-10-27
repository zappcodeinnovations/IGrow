import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Centralized utility for fast, auto-clearing toast notifications & error messages.
/// Default display duration is 1.8 seconds (instead of Flutter's default 4.0s).
/// Calls `clearSnackBars()` before showing a new message so toasts clear instantly.
class AppToast {
  AppToast._();

  static const Duration defaultDuration = Duration(milliseconds: 1800);

  /// Shows a quick, floating toast message that clears previous ones instantly.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = defaultDuration,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    return messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: isError ? Colors.white : const Color(0xFF1B5E20),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isError ? Colors.white : const Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: action == null,
        closeIconColor: isError ? Colors.white70 : const Color(0xFF2E7D32),
        backgroundColor: isError ? AppColors.error : const Color(0xFFDCEFD8),
        action: action,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isError ? Colors.transparent : const Color(0xFFA5D6A7),
            width: 1.2,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
