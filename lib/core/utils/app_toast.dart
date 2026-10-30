import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';

/// Centralized utility for fast, auto-clearing toast notifications & error messages.
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: isError
                  ? Colors.white
                  : (isDark ? AppColors.greenLight : const Color(0xFF2E7D32)),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isError
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.inkDark),
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: action == null,
        closeIconColor: isError
            ? Colors.white70
            : (isDark ? Colors.white70 : AppColors.inkSoft),
        backgroundColor: isError
            ? AppColors.error
            : (isDark ? const Color(0xFF1E2822) : Colors.white),
        action: action,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isError
                ? Colors.transparent
                : (isDark ? AppColors.lineDark : const Color(0xFFD6E2D0)),
            width: 1.2,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

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
                    messenger.hideCurrentSnackBar();
                    final navContext =
                        rootNavigatorKey.currentContext ?? context;
                    final router = GoRouter.of(navContext);
                    router.push(RouteNames.wishlist);
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
