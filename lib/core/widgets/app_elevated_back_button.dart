import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// Reusable Elevated Back Button with squircle shape and soft depth.
class AppElevatedBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String fallbackRoute;

  const AppElevatedBackButton({
    super.key,
    this.onTap,
    this.fallbackRoute = '/onboarding',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap ??
          () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(fallbackRoute);
            }
          },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: AppColors.lineDark) : null,
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x33000000) : const Color(0x14000000),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF1B2E1E),
          ),
        ),
      ),
    );
  }
}
