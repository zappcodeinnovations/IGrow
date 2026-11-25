import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_config_service.dart';
import '../../../core/services/social_auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_gradient_button.dart';
import '../../../core/widgets/app_pill_text_field.dart';
import '../../../core/widgets/app_social_button.dart';
import '../../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import 'complete_phone_profile_bottom_sheet.dart';

/// In-app authentication dialog for guests attempting to make a purchase or enroll.
///
/// Supports instant WhatsApp/SMS Phone OTP verification, Google Sign-In, and Apple Sign-In.
/// Automatically dismisses upon successful authentication and returns `true`.
class QuickAuthDialog extends ConsumerStatefulWidget {
  const QuickAuthDialog({super.key});

  /// Displays the QuickAuthDialog and returns true if login/verification succeeded.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const QuickAuthDialog(),
    );
    return result ?? false;
  }

  @override
  ConsumerState<QuickAuthDialog> createState() => _QuickAuthDialogState();
}

class _QuickAuthDialogState extends ConsumerState<QuickAuthDialog> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isSocialLoading = false;
  String _targetPhone = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendPhoneOtp() async {
    FocusScope.of(context).unfocus();
    final raw = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (raw.length != 10) {
      AppToast.show(
        context,
        tr(ref, 'Mobile number must be exactly 10 digits.'),
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _targetPhone = raw;
    });

    try {
      final success = await ref
          .read(authProvider.notifier)
          .sendPhoneOtp(phoneNumber: raw);
      if (!mounted) return;
      if (success) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
        AppToast.show(
          context,
          tr(ref, 'OTP sent to +91 $raw via WhatsApp/SMS'),
        );
      } else {
        setState(() => _isLoading = false);
        final err = ref.read(authProvider).error ??
            tr(ref, 'Failed to send OTP. Please try again.');
        AppToast.show(context, err, isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.show(context, getUserFriendlyErrorMessage(e), isError: true);
      }
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      AppToast.show(
        context,
        tr(ref, 'Please enter the complete OTP code.'),
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ref
          .read(authProvider.notifier)
          .verifyPhoneOtp(phoneNumber: _targetPhone, otp: otp);

      if (!mounted) return;
      if (res != null) {
        final isNewUser = res['is_new_user'] == true;
        if (isNewUser) {
          final verificationToken = res['verification_token']?.toString() ?? '';
          // First pop the QuickAuthDialog
          Navigator.of(context, rootNavigator: true).pop(false);
          // Show the Complete Profile sheet so user gets token & completes registration
          await CompletePhoneProfileBottomSheet.show(
            context,
            phoneNumber: _targetPhone,
            verificationToken: verificationToken,
            onCompleted: () {
              AppToast.show(context, tr(ref, 'Verification successful!'));
            },
          );
          return;
        }

        AppToast.show(context, tr(ref, 'Verification successful!'));
        Navigator.of(context, rootNavigator: true).pop(true);
      } else {
        setState(() => _isLoading = false);
        _otpController.clear();
        final err = ref.read(authProvider).error ??
            tr(ref, 'Invalid or expired OTP code.');
        AppToast.show(context, err, isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _otpController.clear();
        AppToast.show(context, getUserFriendlyErrorMessage(e), isError: true);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSocialLoading = true);
    try {
      final payload = await SocialAuthService.instance.signInWithGoogle();
      if (payload == null) {
        if (mounted) setState(() => _isSocialLoading = false);
        return;
      }

      final success = await ref
          .read(authProvider.notifier)
          .socialLogin(
            provider: 'google',
            idToken: payload['id_token'] as String,
            fullName: payload['full_name'] as String?,
            fcmToken: payload['fcm_token'] as String?,
          );

      if (!mounted) return;
      if (success) {
        AppToast.show(context, tr(ref, 'Logged in with Google!'));
        Navigator.of(context, rootNavigator: true).pop(true);
      } else {
        setState(() => _isSocialLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSocialLoading = false);
        AppToast.show(context, getUserFriendlyErrorMessage(e), isError: true);
      }
    }
  }

  Future<void> _loginWithApple() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSocialLoading = true);
    try {
      final payload = await SocialAuthService.instance.signInWithApple();
      if (payload == null) {
        if (mounted) setState(() => _isSocialLoading = false);
        return;
      }

      final success = await ref
          .read(authProvider.notifier)
          .socialLogin(
            provider: 'apple',
            idToken: payload['id_token'] as String,
            fullName: payload['full_name'] as String?,
            fcmToken: payload['fcm_token'] as String?,
          );

      if (!mounted) return;
      if (success) {
        AppToast.show(context, tr(ref, 'Logged in with Apple!'));
        Navigator.of(context, rootNavigator: true).pop(true);
      } else {
        setState(() => _isSocialLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSocialLoading = false);
        AppToast.show(context, getUserFriendlyErrorMessage(e), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final config = ref.watch(appConfigProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2822) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.lineDark : AppColors.organicBorderLight,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: keyboardInset > 0 ? 8 : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF223526) : const Color(0xFFEBF6EC),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark ? Colors.white60 : AppColors.inkSoft,
                      ),
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  _isOtpSent ? tr(ref, 'Verify Mobile OTP') : tr(ref, 'Sign in to Continue'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.greenDark,
                    letterSpacing: -0.3,
                  ),
                ),
                if (_isOtpSent) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${tr(ref, 'Enter the 6-digit code sent to')} +91 $_targetPhone',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: isDark ? AppColors.organicSubtitleDark : AppColors.organicSubtitleGreen,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                if (!_isOtpSent) ...[
                  if (config.canShowPhoneLogin) ...[
                    // Phone Number Input
                    AutofillGroup(
                      child: AppPillTextField(
                        controller: _phoneController,
                        hintText: tr(ref, 'Mobile Number'),
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        prefixIcon: Icons.phone_android_rounded,
                        prefix: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF223526) : const Color(0xFFE4EDE3),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '+91',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF4ADE80) : AppColors.greenDark,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        autofillHints: const [
                          AutofillHints.telephoneNumber,
                          AutofillHints.telephoneNumberNational,
                        ],
                        textInputAction: TextInputAction.done,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Send OTP Button
                    AppGradientButton(
                      label: tr(ref, 'Send OTP'),
                      isLoading: _isLoading,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _sendPhoneOtp,
                    ),

                    // Social Logins (Google / Apple)
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? AppColors.lineDark : AppColors.lineLight)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            tr(ref, 'OR'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white38 : AppColors.inkSoft,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? AppColors.lineDark : AppColors.lineLight)),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  AppSocialButton.google(
                    text: tr(ref, 'Continue with Google'),
                    isDark: isDark,
                    isLoading: _isSocialLoading,
                    onPressed: _isSocialLoading ? null : _loginWithGoogle,
                  ),

                  if (!kIsWeb && Platform.isIOS) ...[
                    const SizedBox(height: 10),
                    AppSocialButton.apple(
                      text: tr(ref, 'Continue with Apple'),
                      isDark: isDark,
                      isLoading: _isSocialLoading,
                      onPressed: _isSocialLoading ? null : _loginWithApple,
                    ),
                  ],
                ] else ...[
                  // OTP PIN input
                  Center(
                    child: Pinput(
                      controller: _otpController,
                      length: 6,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      defaultPinTheme: PinTheme(
                        width: 44,
                        height: 50,
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF16251A) : const Color(0xFFF0F5EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.lineDark : AppColors.lineLight,
                          ),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 44,
                        height: 50,
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF16251A) : const Color(0xFFF0F5EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      onCompleted: (_) => _verifyOtp(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verify OTP Button
                  AppGradientButton(
                    label: tr(ref, 'Verify & Proceed'),
                    isLoading: _isLoading,
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 12),

                  // Change Phone / Resend OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _isOtpSent = false),
                        child: Text(
                          tr(ref, 'Change Number'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.inkSoft,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _sendPhoneOtp,
                        child: Text(
                          tr(ref, 'Resend OTP'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
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
