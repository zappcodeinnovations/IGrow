import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../providers/auth_provider.dart';
import 'package:iconly/iconly.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.selectedRole});

  final String? selectedRole;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Immediately dismiss keyboard and clear focus to prevent blank insets
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
        );

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        final hasSelectedLanguage = prefs.getBool('has_selected_language') ?? false;
        if (hasSelectedLanguage) {
          context.go(RouteNames.authSuccess);
        } else {
          context.go(RouteNames.languageSelection);
        }
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
    final inkSoft = Theme.of(context).extension<AppThemeExtension>()?.inkSoft ?? AppColors.inkSoft;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: ResponsiveContentConstraint(
            maxWidth: 520,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                // Back button
                                GestureDetector(
                                  onTap: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go(RouteNames.onboarding);
                                    }
                                  },
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
                                      IconlyLight.arrow_left,
                                      color: isDark ? AppColors.white : AppColors.inkDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  'Welcome Back! 👋',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: inkSoft),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to continue your learning journey.',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: inkSoft),
                                ),
                                const SizedBox(height: 40),
                                // Email / Phone field
                                AppTextField(
                                  controller: _emailController,
                                  label: 'Email or Phone',
                                  hint: 'Enter your email or phone number',
                                  prefixIcon: const Icon(IconlyLight.profile),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Email or Phone is required' : null,
                                ),
                                const SizedBox(height: 16),
                                // Password field
                                AppTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  obscureText: _obscurePassword,
                                  prefixIcon: const Icon(IconlyLight.lock),
                                  autofillHints: const [AutofillHints.password],
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                    child: Icon(
                                      _obscurePassword ? IconlyLight.hide : IconlyLight.show,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _login(),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                                ),
                                const SizedBox(height: 12),
                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.push(RouteNames.forgotPassword),
                                    child: Text(
                                      'Forgot Password?',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: AppColors.primaryGreen,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Login button
                                AppButton(
                                  label: 'Sign In',
                                  onPressed: _login,
                                  isLoading: authState.isLoading,
                                ),
                                const SizedBox(height: 32),
                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: isDark ? AppColors.lineDark : AppColors.lineLight,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'Or continue with',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: inkSoft),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: isDark ? AppColors.lineDark : AppColors.lineLight,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Social login buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SocialButton(
                                        icon: Icons.g_mobiledata_rounded,
                                        label: 'Google',
                                        onTap: () {}, // Placeholder
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _SocialButton(
                                        icon: IconlyLight.call,
                                        label: 'Phone',
                                        onTap: () => context.push(RouteNames.otp),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // Register link
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: inkSoft),
                                      ),
                                      GestureDetector(
                                        onTap: () => context.push(
                                          '${RouteNames.register}?role=${widget.selectedRole ?? 'farmer'}',
                                        ),
                                        child: Text(
                                          'Sign Up',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: AppColors.primaryGreen,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.lineDark : AppColors.lineLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24,
                color: isDark ? AppColors.white : AppColors.inkDark),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: isDark ? AppColors.white : AppColors.inkDark,),
            ),
          ],
        ),
      ),
    );
  }
}
