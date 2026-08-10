import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../providers/auth_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/router/route_names.dart';

/// OTP verification screen — 6-digit input with countdown timer.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.email = '', this.purpose = ''});

  final String email;
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
    await ref.read(authProvider.notifier).resendOtp(email: widget.email);
  }

  Future<void> _verify() async {
    final otp = _otpController.text;
    if (otp.length < 6) return;
    
    setState(() => _isVerifying = true);
    
    // Default to password reset flow if purpose is missing
    if (widget.purpose == 'PASSWORD_RESET' || widget.purpose.isEmpty) {
      final resetToken = await ref.read(authProvider.notifier).verifyResetOtp(
        email: widget.email,
        otp: otp,
      );
      
      if (mounted) {
        setState(() => _isVerifying = false);
        if (resetToken != null) {
          context.push('${RouteNames.createPassword}?token=$resetToken');
        }
      }
    } else {
      // TODO: Handle other OTP purposes (like initial phone verification if needed)
      setState(() => _isVerifying = false);
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
      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(color: isDark ? AppColors.white : AppColors.inkDark,),
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
              Text('Verify OTP 🔐', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${widget.email}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
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
                        'Resend code in ${_secondsLeft}s',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                      )
                    : GestureDetector(
                        onTap: _resendOtp,
                        child: Text(
                          'Resend Code',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryGreen,),
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
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ref.read(authProvider).error!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: AppButton(
                  label: 'Verify',
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
