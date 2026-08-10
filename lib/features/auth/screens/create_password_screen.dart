import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/router/route_names.dart';

/// Create new password screen — after forgot-password reset flow.
class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key, this.token = ''});

  final String token;

  @override
  ConsumerState<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isSaving = false;

  Future<void> _save() async {
    final newPassword = _passwordController.text;
    final confirmPassword = _confirmController.text;
    
    if (newPassword.length < 8) return;
    if (newPassword != confirmPassword) return;
    
    setState(() => _isSaving = true);
    
    final success = await ref.read(authProvider.notifier).resetPassword(
      resetToken: widget.token,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        context.go(RouteNames.login);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    ref.read(authProvider.notifier).clearError();
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
              Text('New Password 🔒', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Create a strong password that\'s at least 8 characters long.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 40),
              AppTextField(
                controller: _passwordController,
                label: 'New Password',
                hint: 'Enter new password',
                obscureText: _obscure1,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscure1 = !_obscure1),
                  child: Icon(_obscure1
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _confirmController,
                label: 'Confirm Password',
                hint: 'Re-enter new password',
                obscureText: _obscure2,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscure2 = !_obscure2),
                  child: Icon(_obscure2
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
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
                  label: 'Reset Password',
                  onPressed: _save,
                  isLoading: _isSaving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
