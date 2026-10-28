import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_social_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/services/social_auth_service.dart';
import '../../../core/widgets/eula_terms_dialog.dart';
import '../../../data/models/user_role.dart';
import '../providers/auth_provider.dart';

/// Registration screen — full form with name, email, phone, password.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.selectedRole});

  final String? selectedRole;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;

  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole == 'instructor'
        ? UserRole.instructor
        : UserRole.farmer;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (ref.read(authProvider).isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) return;

    await ref.read(authProvider.notifier).register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          passwordConfirm: _confirmPasswordController.text,
          role: _selectedRole,
        );

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.status != AuthStatus.error) {
        AppToast.show(
          context,
          'Registration successful! Please login.',
          isError: false,
        );
        context.go('${RouteNames.login}?role=${widget.selectedRole ?? 'farmer'}');
      }
    }
  }

  Future<void> _handleSocialSuccess() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final hasSelectedLanguage = prefs.getBool('has_selected_language') ?? false;
    if (hasSelectedLanguage) {
      context.go(RouteNames.authSuccess);
    } else {
      context.go(RouteNames.languageSelection);
    }
  }

  Future<void> _loginWithGoogle() async {
    FocusScope.of(context).unfocus();
    try {
      print('\n👉 [REGISTER_SCREEN] Starting Google Sign-In...');
      final payload = await SocialAuthService.instance.signInWithGoogle();
      if (payload == null) {
        print('⚠️ [REGISTER_SCREEN] Google Sign-In returned null (user canceled or no credential available).');
        if (mounted) {
          AppToast.show(
            context,
            'Google Sign-In was cancelled or no credential was returned.',
            isError: true,
          );
        }
        return;
      }

      print('✅ [REGISTER_SCREEN] Google Sign-In token received. Sending to backend...');
      final success = await ref.read(authProvider.notifier).socialLogin(
            provider: 'google',
            idToken: payload['id_token'] as String,
            fullName: payload['full_name'] as String?,
            fcmToken: payload['fcm_token'] as String?,
          );

      if (success) {
        print('✅ [REGISTER_SCREEN] Backend social register/login success! Navigating...');
        await _handleSocialSuccess();
      } else {
        print('❌ [REGISTER_SCREEN] Backend social register/login failed: ${ref.read(authProvider).error}');
      }
    } catch (e, st) {
      print('❌ [REGISTER_SCREEN] Google Sign-In Exception: $e\n$st');
      if (mounted) {
        AppToast.show(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    }
  }

  Future<void> _loginWithApple() async {
    FocusScope.of(context).unfocus();
    try {
      final payload = await SocialAuthService.instance.signInWithApple();
      if (payload == null) return;

      final success = await ref.read(authProvider.notifier).socialLogin(
            provider: 'apple',
            idToken: payload['id_token'] as String,
            fullName: payload['full_name'] as String?,
            fcmToken: payload['fcm_token'] as String?,
          );

      if (success) {
        await _handleSocialSuccess();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.error != null) {
        AppToast.show(context, next.error!, isError: true);
        ref.read(authProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContentConstraint(
          maxWidth: 540,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(
                        '${RouteNames.login}?role=${widget.selectedRole ?? 'farmer'}',
                      );
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            isDark ? AppColors.lineDark : AppColors.lineLight,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? AppColors.white : AppColors.inkDark,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Create Account 🌱', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Join as ${_selectedRole.label} and start your journey.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 32),
                // Role Selection
                Text(
                  'Select Your Role',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleSelectCard(
                        role: UserRole.farmer,
                        isSelected: _selectedRole == UserRole.farmer,
                        onTap: () => setState(() => _selectedRole = UserRole.farmer),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RoleSelectCard(
                        role: UserRole.instructor,
                        isSelected: _selectedRole == UserRole.instructor,
                        onTap: () => setState(() => _selectedRole = UserRole.instructor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Valid email required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+91 XXXXX XXXXX',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.length < 10) ? 'Valid phone required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Create a strong password',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.length < 4)
                      ? 'Min 4 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  obscureText: _obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (v) => v != _passwordController.text
                      ? 'Passwords don\'t match'
                      : null,
                ),
                const SizedBox(height: 20),
                // Terms checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeTerms,
                        onChanged: (v) =>
                            setState(() => _agreeTerms = v ?? false),
                        activeColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => EulaTermsDialog.show(context),
                        behavior: HitTestBehavior.opaque,
                        child: Text.rich(
                          TextSpan(
                            text: 'By continuing, you agree to our ',
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text: 'Terms of Use (EULA)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                              const TextSpan(
                                text:
                                    ' and zero-tolerance policy against objectionable content and abusive users.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                AppButton(
                  label: 'Create Account',
                  onPressed: _agreeTerms ? _register : null,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: 20),

                // Modern "OR" Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark ? AppColors.lineDark : AppColors.lineLight,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'OR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : AppColors.inkSoft,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark ? AppColors.lineDark : AppColors.lineLight,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Google Sign Up
                AppSocialButton.google(
                  text: 'Sign up with Google',
                  isDark: isDark,
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading ? null : _loginWithGoogle,
                ),

                // Apple Sign Up (iOS only)
                if (Platform.isIOS) ...[
                  const SizedBox(height: 12),
                  AppSocialButton.apple(
                    text: 'Sign up with Apple',
                    isDark: isDark,
                    isLoading: authState.isLoading,
                    onPressed: authState.isLoading ? null : _loginWithApple,
                  ),
                ],

                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account? ',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(
                              '${RouteNames.login}?role=${widget.selectedRole ?? 'farmer'}',
                            );
                          }
                        },
                        child: Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryGreen,),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _RoleSelectCard extends StatelessWidget {
  const _RoleSelectCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.1)
              : (isDark ? AppColors.cardDark : AppColors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.lineDark : AppColors.lineLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              role.icon,
              size: 28,
              color: isSelected ? AppColors.primaryGreen : AppColors.inkSoft,
            ),
            const SizedBox(height: 8),
            Text(
              role.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : (isDark ? AppColors.white : AppColors.inkDark),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
