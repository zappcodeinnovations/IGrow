import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../widgets/app_error_state.dart';

/// Severity level for toast and notification banners.
enum ToastSeverity {
  /// Polite validation notices, guidance, non-blocking form warnings.
  /// Uses a soft, warm amber/orange accent with dark rounded styling.
  warning,

  /// Severe/critical system failures, network crashes, payment or account errors.
  /// Uses an elegant dark surface with soft crimson accent borders.
  error,

  /// Success affirmations with agricultural green accent.
  success,

  /// General informative messages.
  info,
}

/// Centralized utility for fast, auto-clearing toast notifications & error messages.
class AppToast {
  AppToast._();

  static const Duration defaultDuration = Duration(milliseconds: 2400);

  /// Shows a quick, floating toast message with elegant dark-mode rounded styling.
  /// [isError] is maintained for backward compatibility.
  /// [severity] specifies whether this is a gentle validation notice ([ToastSeverity.warning]),
  /// a severe system failure ([ToastSeverity.error]), or a positive success ([ToastSeverity.success]).
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    bool isError = false,
    ToastSeverity? severity,
    Duration duration = defaultDuration,
    SnackBarAction? action,
    IconData? customIcon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    // Sanitize any error message or technical exception passed into toast
    final cleanMessage = (isError || severity == ToastSeverity.error || severity == ToastSeverity.warning)
        ? getUserFriendlyErrorMessage(message, fallback: message)
        : message;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ToastSeverity effectiveSeverity = severity ??
        (isError ? ToastSeverity.warning : ToastSeverity.success);

    // Compute semantic palette tailored for the app's aesthetic:
    final (
      Color iconBg,
      Color iconColor,
      IconData icon,
      Color bg,
      Color borderColor,
    ) = switch (effectiveSeverity) {
      ToastSeverity.warning => (
          isDark
              ? const Color(0xFFF59E0B).withValues(alpha: 0.16)
              : const Color(0xFFFFFBEB),
          isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          customIcon ?? Icons.info_outline_rounded,
          isDark ? const Color(0xFF1E201B) : Colors.white,
          isDark
              ? const Color(0xFFF59E0B).withValues(alpha: 0.38)
              : const Color(0xFFFDE68A),
        ),
      ToastSeverity.error => (
          isDark
              ? const Color(0xFFEF4444).withValues(alpha: 0.16)
              : const Color(0xFFFEF2F2),
          isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          customIcon ?? Icons.error_outline_rounded,
          isDark ? const Color(0xFF231B1C) : Colors.white,
          isDark
              ? const Color(0xFFEF4444).withValues(alpha: 0.40)
              : const Color(0xFFFECACA),
        ),
      ToastSeverity.success => (
          isDark
              ? AppColors.primaryGreen.withValues(alpha: 0.2)
              : const Color(0xFFE8F5E9),
          isDark ? AppColors.greenLight : const Color(0xFF2E7D32),
          customIcon ?? Icons.check_circle_rounded,
          isDark ? const Color(0xFF1B231D) : Colors.white,
          isDark ? const Color(0xFF2E4334) : const Color(0xFFD6E2D0),
        ),
      ToastSeverity.info => (
          isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFF3F4F6),
          isDark ? Colors.white70 : const Color(0xFF4B5563),
          customIcon ?? Icons.info_outline_rounded,
          isDark ? const Color(0xFF1E1E1E) : Colors.white,
          isDark ? AppColors.lineDark : const Color(0xFFE5E7EB),
        ),
    };

    return messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                cleanMessage,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.inkDark,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: action == null,
        closeIconColor: isDark ? Colors.white70 : AppColors.inkSoft,
        backgroundColor: bg,
        action: action,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1.2),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  /// Polite validation warning toast (non-threatening, rounded dark container with subtle amber highlight).
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWarning(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    SnackBarAction? action,
  }) {
    return show(
      context,
      message,
      severity: ToastSeverity.warning,
      duration: duration,
      action: action,
    );
  }

  /// Informational toast with calm neutral styling.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfo(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    SnackBarAction? action,
  }) {
    return show(
      context,
      message,
      severity: ToastSeverity.info,
      duration: duration,
      action: action,
    );
  }

  /// Critical/heavy error toast (system crash, payment failure, server outage).
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    return show(
      context,
      message,
      severity: ToastSeverity.error,
      duration: duration,
      action: action,
    );
  }

  /// Automatically extracts user-friendly message, masking raw socket exceptions with
  /// "No internet connection. Please try again later."
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showFriendlyError(
    BuildContext context,
    dynamic error, {
    String? prefix,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final cleanMsg = getUserFriendlyErrorMessage(error);
    final isNetwork = isOfflineOrNetworkError(error);
    final String message;
    if (isNetwork) {
      message = cleanMsg; // Never show "Failed to ...: No internet" - show clean offline banner
    } else if (prefix != null && prefix.isNotEmpty) {
      message = '$prefix: $cleanMsg';
    } else {
      message = cleanMsg;
    }

    return showError(
      context,
      message,
      duration: duration,
      action: action,
    );
  }

  /// Positive action confirmation toast.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccess(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    SnackBarAction? action,
  }) {
    return show(
      context,
      message,
      severity: ToastSeverity.success,
      duration: duration,
      action: action,
    );
  }

  static DateTime? _lastWishlistNavTime;

  /// Premium, compact floating banner specifically for Wishlist interactions.
  static void showWishlistToast(BuildContext context, {required bool isAdded}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    messenger.showSnackBar(
      SnackBar(
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 3200),
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C251F) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E4334) : const Color(0xFFDCEAD8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isAdded
                      ? (isDark
                            ? AppColors.primaryGreen.withValues(alpha: 0.2)
                            : const Color(0xFFE8F5E9))
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF5F5F5)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAdded ? Icons.favorite_rounded : Icons.heart_broken_rounded,
                  color: isAdded
                      ? Colors.redAccent
                      : (isDark ? Colors.white60 : Colors.grey),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAdded ? 'Added to Wishlist' : 'Removed from Wishlist',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    if (isAdded)
                      Text(
                        'Saved for quick access',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white60 : AppColors.inkSoft,
                        ),
                      ),
                  ],
                ),
              ),
              if (isAdded)
                InkWell(
                  onTap: () {
                    final now = DateTime.now();
                    if (_lastWishlistNavTime != null &&
                        now.difference(_lastWishlistNavTime!).inMilliseconds < 1000) {
                      return;
                    }
                    _lastWishlistNavTime = now;
                    messenger.hideCurrentSnackBar();
                    final navContext =
                        rootNavigatorKey.currentContext ?? context;
                    if (navContext.mounted) {
                      navContext.push(RouteNames.wishlist);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryGreen.withValues(alpha: 0.25)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.greenLight
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: isDark
                              ? AppColors.greenLight
                              : const Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
