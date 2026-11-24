import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/app_gradient_button.dart';
import '../../../core/widgets/app_pill_text_field.dart';
import '../../../data/models/user_model.dart';
import '../providers/auth_provider.dart';

/// Compact modal prompt to request the user's mobile number before purchase or operations.
///
/// Role selection, state, and district selectors have been removed per UX update.
/// City and state are auto-resolved in the background.
class CompleteSocialProfileDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const CompleteSocialProfileDialog({
    super.key,
    required this.user,
  });

  /// Whether a CompleteSocialProfileDialog is currently visible on screen.
  static bool isOpen = false;

  /// Helper checking if the user profile is missing a valid phone number.
  static bool isProfileIncomplete(UserModel? user) {
    if (user == null) return false;
    return user.phone.trim().isEmpty;
  }

  /// Static helper to display the dialog and return true if completed
  static Future<bool> show(BuildContext context, UserModel user) async {
    isOpen = true;
    try {
      final res = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => PopScope(
          canPop: true,
          child: CompleteSocialProfileDialog(user: user),
        ),
      );
      return res ?? false;
    } finally {
      isOpen = false;
    }
  }

  @override
  ConsumerState<CompleteSocialProfileDialog> createState() =>
      _CompleteSocialProfileDialogState();
}

class _CompleteSocialProfileDialogState
    extends ConsumerState<CompleteSocialProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    String initialPhone = widget.user.phone.trim();
    if (initialPhone.startsWith('+91')) {
      initialPhone = initialPhone.substring(3).trim();
    } else if (initialPhone.startsWith('91') && initialPhone.length > 10) {
      initialPhone = initialPhone.substring(2).trim();
    }
    _phoneController = TextEditingController(text: initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _dismissDialog(bool success) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(success);
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    var phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length > 10 && phone.startsWith('91')) {
      phone = phone.substring(2);
    }
    final formattedPhone = phone.isNotEmpty ? '+91$phone' : null;

    setState(() => _isSaving = true);

    try {
      final request = PatchedUserProfileRequest(
        phoneNumber: formattedPhone,
      );

      await ref.read(authProvider.notifier).updateProfile(request);

      if (mounted) {
        AppToast.show(context, tr(ref, 'Phone number saved successfully!'));
        _dismissDialog(true);
      }
    } catch (e) {
      if (mounted) {
        String msg = tr(ref, 'Failed to save phone number. Please try again.');
        if (e is ApiException) {
          if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
            final firstEntry = e.fieldErrors!.entries.first;
            final fieldName = firstEntry.key == 'phone_number' ? tr(ref, 'Phone number') : firstEntry.key;
            final errText = firstEntry.value.isNotEmpty ? firstEntry.value.first : 'Invalid';
            msg = '$fieldName: $errText';
          } else if (e.message.isNotEmpty) {
            msg = e.message;
          }
        }
        AppToast.show(
          context,
          msg,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2822) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.lineDark : AppColors.organicBorderLight,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: keyboardInset > 0 ? 8 : 0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Close button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0xFF223526) : const Color(0xFFEBF6EC),
                          ),
                          child: const Icon(
                            Icons.phone_android_rounded,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: isDark ? Colors.white60 : AppColors.inkSoft,
                          ),
                          onPressed: () => _dismissDialog(false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      tr(ref, 'Mobile Number Required'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.greenDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      tr(
                        ref,
                        'Please provide your mobile number to complete enrollment and receive purchase updates.',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.organicSubtitleDark
                            : AppColors.organicSubtitleGreen,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Phone Field (Mandatory)
                    AppPillTextField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      hintText: tr(ref, 'Mobile Number (10 digits) *'),
                      prefixIcon: Icons.phone_rounded,
                      prefix: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF223526) : const Color(0xFFE4EDE3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+91',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF4ADE80) : AppColors.greenDark,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        final raw = (value ?? '').trim();
                        var digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
                        if (digitsOnly.length > 10 && digitsOnly.startsWith('91')) {
                          digitsOnly = digitsOnly.substring(2);
                        }
                        if (digitsOnly.isEmpty) {
                          return tr(ref, 'Phone number is required');
                        }
                        if (digitsOnly.length != 10) {
                          return tr(ref, 'Phone number must be exactly 10 digits');
                        }
                        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digitsOnly)) {
                          return tr(ref, 'Enter a valid 10-digit mobile number');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Save and Continue Button
                    AppGradientButton(
                      label: tr(ref, 'Continue'),
                      isLoading: _isSaving,
                      onPressed: _isSaving ? () {} : () => _saveAndContinue(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
