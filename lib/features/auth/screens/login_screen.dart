import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_elevated_back_button.dart';
import '../../../core/widgets/app_gradient_button.dart';
import '../../../core/widgets/app_pill_text_field.dart';
import '../../../core/widgets/eula_terms_dialog.dart';
import '../../../core/widgets/organic_background.dart';
import '../providers/auth_provider.dart';

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
    // Dismiss keyboard immediately to prevent layout jumps
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
        );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final hasSelectedLanguage =
          prefs.getBool('has_selected_language') ?? false;
      if (hasSelectedLanguage) {
        context.go(RouteNames.authSuccess);
      } else {
        context.go(RouteNames.languageSelection);
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: OrganicBackground(
        child: SafeArea(
          child: ResponsiveContentConstraint(
            maxWidth: 500,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Reusable Elevated Back Button
                        const AppElevatedBackButton(
                          fallbackRoute: RouteNames.onboarding,
                        ),

                        const SizedBox(height: 28),

                        // Headline: "Welcome"
                        Text(
                          'Welcome',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.organicHeadingDark
                                : AppColors.organicHeadingGreen,
                            height: 1.12,
                            letterSpacing: -0.6,
                          ),
                        ),

                        // Headline: "Back! 👏" with celebratory accents
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Back!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.organicOliveDark
                                    : AppColors.organicOliveGreen,
                                height: 1.15,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                const Text(
                                  '👏',
                                  style: TextStyle(fontSize: 34),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -7,
                                  child: CustomPaint(
                                    size: const Size(20, 20),
                                    painter: EmojiCelebrationPainter(isDark: isDark),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          'Sign in to continue your learning journey.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.organicSubtitleDark
                                : AppColors.organicSubtitleGreen,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Input Card: Email or Phone (Reusable AppPillTextField)
                        AppPillTextField(
                          controller: _emailController,
                          hintText: 'Email or Phone',
                          prefixIcon: IconlyLight.profile,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.email,
                            AutofillHints.username,
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email or Phone is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Input Card: Password (Reusable AppPillTextField)
                        AppPillTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: IconlyLight.lock,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onSubmitted: (_) => _login(),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Icon(
                                _obscurePassword
                                    ? IconlyLight.hide
                                    : IconlyLight.show,
                                size: 21,
                                color: isDark
                                    ? AppColors.organicIconDark
                                    : AppColors.organicIconLight,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // Right-aligned "Forgot Password?" with clean green underline
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => context.push(RouteNames.forgotPassword),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 2,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.organicActionLinkDark
                                      : AppColors.organicActionLink,
                                  decoration: TextDecoration.underline,
                                  decorationColor: isDark
                                      ? AppColors.organicActionLinkDark
                                      : AppColors.organicActionLink,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // EULA / Terms Notice required by Apple Guideline 1.2
                        GestureDetector(
                          onTap: () => EulaTermsDialog.show(context),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text.rich(
                              TextSpan(
                                text: 'By continuing, you agree to our ',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: isDark ? Colors.white70 : AppColors.inkSoft,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Use (EULA)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.organicActionLinkDark
                                          : AppColors.organicActionLink,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' and zero-tolerance policy against objectionable content and abusive users.',
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Reusable HD Green Gradient Pill Sign In Button
                        AppGradientButton(
                          label: 'Sign In',
                          isLoading: authState.isLoading,
                          onPressed: _login,
                        ),

                        const SizedBox(height: 36),

                        // Bottom Sign Up Link
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFFB0C4AF)
                                      : const Color(0xFF1E2B1F),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push(
                                  '${RouteNames.register}?role=${widget.selectedRole ?? 'farmer'}',
                                ),
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  'Sign Up',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.organicActionLinkDark
                                        : const Color(0xFF0F5B24),
                                  ),
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
          ),
        ),
      ),
    );
  }
}
