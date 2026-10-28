import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clean, high-aesthetic social login button conforming to brand design guidelines.
class AppSocialButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const AppSocialButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  /// Factory for Google Sign In Button
  factory AppSocialButton.google({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    required bool isDark,
  }) {
    return AppSocialButton(
      key: key,
      text: text,
      icon: Image.network(
        'https://fonts.gstatic.com/s/i/productlogos/googleg/v6/24px.svg',
        width: 22,
        height: 22,
        errorBuilder: (context, error, stackTrace) => const _GoogleFallbackIcon(),
      ),
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: isDark ? const Color(0xFF1E2820) : Colors.white,
      textColor: isDark ? Colors.white : const Color(0xFF1F2937),
      borderColor: isDark ? const Color(0xFF2C3E2F) : const Color(0xFFE5E7EB),
    );
  }

  /// Factory for Apple Sign In Button
  factory AppSocialButton.apple({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    required bool isDark,
  }) {
    return AppSocialButton(
      key: key,
      text: text,
      icon: Icon(
        Icons.apple,
        size: 24,
        color: isDark ? Colors.black : Colors.white,
      ),
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: isDark ? Colors.white : Colors.black,
      textColor: isDark ? Colors.black : Colors.white,
      borderColor: isDark ? Colors.white : Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor ?? const Color(0xFFE5E7EB),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: isLoading ? null : onPressed,
          splashColor: Colors.black.withValues(alpha: 0.05),
          highlightColor: Colors.black.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.black87,
                      ),
                    ),
                  )
                else ...[
                  icon,
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? const Color(0xFF1F2937),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback custom painted Google icon in case SVG or network asset is unavailable
class _GoogleFallbackIcon extends StatelessWidget {
  const _GoogleFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          'G',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
