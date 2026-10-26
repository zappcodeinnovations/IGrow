import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Reusable Stadium/Pill Input Field with Frosted Glass look.
///
/// Features:
/// - Smooth rounded container (28px stadium radius)
/// - Circular leading icon badge
/// - Auto light/dark theme adaptation
/// - Resolves dark-theme `fillColor` clashing
/// - Embedded validation error text
class AppPillTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  const AppPillTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<AppPillTextField> createState() => _AppPillTextFieldState();
}

class _AppPillTextFieldState extends State<AppPillTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FormField<String>(
      validator: widget.validator,
      initialValue: widget.controller.text,
      builder: (fieldState) {
        final hasError = fieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.organicCardDark
                    : AppColors.organicCardLight,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: hasError
                      ? const Color(0xFFEF5350)
                      : (_isFocused
                          ? (isDark
                              ? AppColors.organicActionLinkDark
                              : const Color(0xFF2E6E34))
                          : (isDark
                              ? AppColors.organicBorderDark
                              : AppColors.organicBorderLight)),
                  width: _isFocused ? 1.5 : 1.2,
                ),
                boxShadow: AppColors.organicCardShadow(isDark: isDark),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 9),

                  // Circular Badge for Leading Icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.organicBadgeDark
                          : AppColors.organicBadgeLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        widget.prefixIcon,
                        size: 19,
                        color: isDark
                            ? AppColors.organicIconDark
                            : AppColors.organicIconLight,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Text Input
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      autofillHints: widget.autofillHints,
                      onSubmitted: widget.onSubmitted,
                      onChanged: (val) {
                        fieldState.didChange(val);
                      },
                      cursorColor: isDark
                          ? AppColors.organicActionLinkDark
                          : const Color(0xFF266535),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1B331F),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent, // Prevents theme fillColor override
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: widget.hintText,
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? AppColors.organicHintDark
                              : AppColors.organicHintLight,
                        ),
                      ),
                    ),
                  ),

                  // Optional Suffix Widget (Eye icon, etc.)
                  if (widget.suffixIcon != null) widget.suffixIcon!,
                ],
              ),
            ),

            // Inline Validation Error Message
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 6),
                child: Text(
                  fieldState.errorText!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFEF5350),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
