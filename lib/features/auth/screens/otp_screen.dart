import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../widgets/complete_phone_profile_bottom_sheet.dart';
import '../widgets/dual_role_select_bottom_sheet.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/user_role.dart';

/// OTP verification screen — 6-digit input with countdown timer.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    this.email = '',
    this.phone = '',
    this.purpose = '',
  });

  final String email;
  final String phone;
  final String purpose;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  int _secondsLeft = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resendOtp() async {
    _startTimer();
    ref.read(authProvider.notifier).clearError();
    if (widget.purpose == 'PHONE_LOGIN' && widget.phone.isNotEmpty) {
      final success = await ref
          .read(authProvider.notifier)
          .sendPhoneOtp(phoneNumber: widget.phone);
      if (mounted) {
        if (success) {
          _otpController.clear();
          AppToast.show(context, tr(ref, 'New OTP sent to your WhatsApp number.'));
        } else {
          final error = ref.read(authProvider).error;
          if (error != null) {
            AppToast.show(context, tr(ref, error), isError: true);
          }
        }
      }
    } else {
      final success = await ref
          .read(authProvider.notifier)
          .resendOtp(email: widget.email);
      if (mounted) {
        if (success) {
          _otpController.clear();
          AppToast.show(context, tr(ref, 'New OTP code sent to your email.'));
        } else {
          final error = ref.read(authProvider).error;
          if (error != null) {
            AppToast.show(context, tr(ref, error), isError: true);
          }
        }
      }
    }
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) return;

    setState(() => _isVerifying = true);
    ref.read(authProvider.notifier).clearError();

    // ─── 1. WhatsApp Phone OTP Flow ──────────────────────────────────
    if (widget.purpose == 'PHONE_LOGIN') {
      final res = await ref
          .read(authProvider.notifier)
          .verifyPhoneOtp(phoneNumber: widget.phone, otp: otp);

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (res != null) {
        final isNewUser = res['is_new_user'] == true;
        if (isNewUser) {
          // Outcome B: New User -> Complete Profile BottomSheet
          final verificationToken = res['verification_token']?.toString() ?? '';
          await CompletePhoneProfileBottomSheet.show(
            context,
            phoneNumber: widget.phone,
            verificationToken: verificationToken,
            onCompleted: () => _handleLoginSuccess(),
          );
        } else {
          // Outcome A: Existing User -> Show Student or Instructor choice pop up
          final rawRoles = res['available_roles'] as List<dynamic>?;
          final availableRoles =
              rawRoles
                  ?.map((r) => UserRole.fromApiValue(r.toString()))
                  .toList() ??
              [];
          final user = ref.read(authProvider).user;
          final granted = (user?.grantedRoles.isNotEmpty == true)
              ? user!.grantedRoles
              : (availableRoles.isNotEmpty
                  ? availableRoles
                  : const [UserRole.farmer, UserRole.instructor]);

          final chosenRole = await DualRoleSelectBottomSheet.show(
            context,
            availableRoles: granted,
          );
          if (chosenRole != null) {
            if (chosenRole == UserRole.instructor && !granted.contains(UserRole.instructor)) {
              await ref.read(authProvider.notifier).becomeInstructor();
            } else if (chosenRole != user?.activeRole) {
              await ref.read(authProvider.notifier).switchRole(chosenRole);
            }
          }
          if (mounted) {
            await _handleLoginSuccess();
          }
        }
      } else {
        final errorMsg =
            ref.read(authProvider).error ?? 'Invalid or expired OTP.';
        _otpController.clear();
        AppToast.show(context, errorMsg, isError: true);
      }
      return;
    }

    // ─── 2. Password Reset Flow ──────────────────────────────────────
    if (widget.purpose == 'PASSWORD_RESET' || widget.purpose.isEmpty) {
      final resetToken = await ref
          .read(authProvider.notifier)
          .verifyResetOtp(email: widget.email, otp: otp);

      if (mounted) {
        setState(() => _isVerifying = false);
        if (resetToken != null) {
          context.push('${RouteNames.createPassword}?token=$resetToken');
        } else {
          final errorMsg =
              ref.read(authProvider).error ??
              tr(ref, 'Invalid or expired OTP. Please request a new code.');
          _otpController.clear();
          AppToast.show(context, tr(ref, errorMsg), isError: true);
        }
      }
    } else {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _handleLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    final user = ref.read(authProvider).user;
    if (user != null) {
      final roleStr = user.activeRole == UserRole.instructor
          ? 'instructor'
          : 'farmer';
      await prefs.setString('active_user_role', roleStr);
      await prefs.setString('selected_auth_role', roleStr);
    }

    if (!mounted) return;
    final hasSelectedLanguage = prefs.getBool('has_selected_language') ?? false;
    if (hasSelectedLanguage) {
      context.go(RouteNames.authSuccess);
    } else {
      context.go(RouteNames.languageSelection);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    ref.read(authProvider.notifier).clearError();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: isDark ? AppColors.white : AppColors.inkDark,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.lineDark : AppColors.lineLight,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.lineDark : AppColors.lineLight,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? AppColors.white : AppColors.inkDark,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                tr(ref, 'Verify OTP 🔐'),
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.purpose == 'PHONE_LOGIN'
                    ? '${tr(ref, 'We sent a 6-digit WhatsApp OTP to ')}${widget.phone}'
                    : '${tr(ref, 'We sent a 6-digit code to ')}${widget.email}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 48),
              // OTP input
              Center(
                child: Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onCompleted: (_) => _verify(),
                ),
              ),
              const SizedBox(height: 32),
              // Resend timer
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        '${tr(ref, 'Resend code in ')}${formatNum(ref, _secondsLeft)}s',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkSoft,
                        ),
                      )
                    : GestureDetector(
                        onTap: _resendOtp,
                        child: Text(
                          tr(ref, 'Resend Code'),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.primaryGreen),
                        ),
                      ),
              ),
              const Spacer(),
              if (ref.watch(authProvider).error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tr(ref, ref.read(authProvider).error!),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: AppButton(
                  label: tr(ref, 'Verify'),
                  onPressed: _verify,
                  isLoading: _isVerifying,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
