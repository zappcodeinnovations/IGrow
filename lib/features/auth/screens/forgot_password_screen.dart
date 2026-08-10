import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/router/route_names.dart';

/// Forgot password screen — enter email/phone to receive reset link/OTP.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _send() async {
    final email = _controller.text.trim();
    if (email.isEmpty) return;
    
    setState(() => _isSending = true);
    
    final success = await ref.read(authProvider.notifier).forgotPassword(
      email: email,
    );
    
    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        context.push('${RouteNames.otp}?email=$email&purpose=PASSWORD_RESET');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  child: Icon(Icons.arrow_back_rounded,
                      color: isDark ? AppColors.white : AppColors.inkDark),
                ),
              ),
              const SizedBox(height: 32),
              Text('Forgot Password? 🔑', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'No worries! Enter your email and we\'ll send you an OTP.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 40),
              AppTextField(
                controller: _controller,
                label: 'Email',
                hint: 'Enter your registered email',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _send(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: AppButton(
                  label: 'Send Reset Link',
                  onPressed: _send,
                  isLoading: _isSending,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
