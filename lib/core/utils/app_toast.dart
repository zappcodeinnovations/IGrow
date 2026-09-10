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
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        closeIconColor: Colors.white70,
        backgroundColor: isError ? AppColors.error : AppColors.primaryGreen,
        action: action,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
