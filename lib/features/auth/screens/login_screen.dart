import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_elevated_back_button.dart';
import '../../../core/widgets/app_gradient_button.dart';
import '../../../core/widgets/app_pill_text_field.dart';
import '../../../core/widgets/app_social_button.dart';
import '../../../core/widgets/eula_terms_dialog.dart';
import '../../../core/widgets/organic_background.dart';
import '../../../core/services/social_auth_service.dart';
import '../../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import '../widgets/complete_social_profile_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.selectedRole});

  final String? selectedRole;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  final _emailFormKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isPhoneLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isEmailLoading = false;
  bool _showEmailFields = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSocialSuccess() async {
    if (!mounted) return;

    final user = ref.read(authProvider).user;
    final needsDetails =
        user != null &&
        (user.phone.trim().isEmpty ||
            (user.locationState == null || user.locationState!.trim().isEmpty));

    if (needsDetails) {
      await CompleteSocialProfileDialog.show(context, user);
      if (!mounted) return;
    }

    final updatedUser = ref.read(authProvider).user ?? user;
    if (updatedUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final backendRole = updatedUser.activeRole;
    if (backendRole == UserRole.instructor) {
      await prefs.setString('active_user_role', 'instructor');
      await prefs.setString('selected_auth_role', 'instructor');
    } else {
      await prefs.setString('active_user_role', 'farmer');
      await prefs.setString('selected_auth_role', 'farmer');
    }

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
    setState(() => _isGoogleLoading = true);
    try {
      final payload = await SocialAuthService.instance.signInWithGoogle();
      if (payload == null) {
        if (mounted) {
          AppToast.show(
            context,
            tr(ref, 'Google Sign-In was cancelled.'),
            isError: true,
          );
        }
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

      if (success) {
        await _handleSocialSuccess();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, getUserFriendlyErrorMessage(e), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _loginWithApple() async {
    FocusScope.of(context).unfocus();
    setState(() => _isAppleLoading = true);
    try {
      final payload = await SocialAuthService.instance.signInWithApple();
      if (payload == null) return;

      final success = await ref
          .read(authProvider.notifier)
          .socialLogin(
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
        AppToast.show(context, getUserFriendlyErrorMessage(e), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  Future<void> _sendPhoneOtp() async {
    FocusScope.of(context).unfocus();
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      AppToast.show(
        context,
        tr(ref, 'Mobile number must be exactly 10 digits.'),
        isError: true,
      );
      return;
    }

    setState(() => _isPhoneLoading = true);
    try {
      // In SMS Gateway flow, navigate to OTP verification screen with phone number
      context.push('${RouteNames.otp}?phone=$phone&purpose=PHONE_LOGIN');
    } finally {
      if (mounted) {
        setState(() => _isPhoneLoading = false);
      }
    }
  }

  Future<void> _loginWithEmail() async {
    FocusScope.of(context).unfocus();
    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isEmailLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .login(email: email, password: password);

      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState.isAuthenticated && authState.user != null) {
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
    } finally {
      if (mounted) {
        setState(() => _isEmailLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if ((next.status == AuthStatus.error ||
              next.status == AuthStatus.unauthenticated) &&
          next.error != null &&
          next.error!.isNotEmpty &&
          previous?.error != next.error) {
        final errorMsg = next.error!;
        AppToast.show(
          context,
          tr(ref, getUserFriendlyErrorMessage(errorMsg)),
          isError: true,
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isAnyLoading =
        _isGoogleLoading ||
        _isAppleLoading ||
        _isPhoneLoading ||
        _isEmailLoading;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Back Button leading back to Language Selection
                    const AppElevatedBackButton(
                      fallbackRoute: RouteNames.languageSelection,
                    ),

                    const SizedBox(height: 26),

                    // Brand Heading
                    Text(
                      tr(ref, 'Welcome to'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.organicHeadingDark
                            : AppColors.organicHeadingGreen,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'iAgrow 🌱',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.organicOliveDark
                            : AppColors.organicOliveGreen,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      tr(
                        ref,
                        'Sign in with your preferred option to continue.',
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColors.organicSubtitleDark
                            : AppColors.organicSubtitleGreen,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 1. TOP SOCIAL SIGN-IN OPTIONS
                    // Google Sign-In Button
                    AppSocialButton.google(
                      text: tr(ref, 'Continue with Google'),
                      isDark: isDark,
                      isLoading: _isGoogleLoading,
                      onPressed: isAnyLoading ? null : _loginWithGoogle,
                    ),

                    // Apple Sign-In Button (iOS only)
                    if (Platform.isIOS) ...[
                      const SizedBox(height: 12),
                      AppSocialButton.apple(
                        text: tr(ref, 'Sign in with Apple'),
                        isDark: isDark,
                        isLoading: _isAppleLoading,
                        onPressed: isAnyLoading ? null : _loginWithApple,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Divider with "OR"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? AppColors.lineDark
                                : AppColors.organicBorderLight,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            tr(ref, 'OR CONTINUE WITH PHONE').toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.organicSubtitleDark
                                  : AppColors.organicSubtitleGreen,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? AppColors.lineDark
                                : AppColors.organicBorderLight,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 2. SIGN IN WITH MOBILE NUMBER
                    AppPillTextField(
                      controller: _phoneController,
                      hintText: tr(ref, 'Enter 10-digit mobile number'),
                      prefixIcon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted: (_) => _sendPhoneOtp(),
                    ),

                    const SizedBox(height: 14),

                    AppGradientButton(
                      label: tr(ref, 'Get OTP'),
                      isLoading: _isPhoneLoading,
                      onPressed: isAnyLoading ? () {} : () => _sendPhoneOtp(),
                    ),

                    const SizedBox(height: 20),

                    // 3. DISCREET "OR USE EMAIL AND PASSWORD" TEXT LINK
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showEmailFields = !_showEmailFields;
                          });
                          if (_showEmailFields) {
                            Future.delayed(
                              const Duration(milliseconds: 150),
                              () {
                                if (_scrollController.hasClients) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                            );
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tr(
                                  ref,
                                  _showEmailFields
                                      ? 'Hide email sign in'
                                      : 'or use email and password',
                                ),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
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
                              const SizedBox(width: 4),
                              Icon(
                                _showEmailFields
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: isDark
                                    ? AppColors.organicActionLinkDark
                                    : AppColors.organicActionLink,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Expandable Email / Password Form
                    if (_showEmailFields) ...[
                      const SizedBox(height: 16),
                      Form(
                        key: _emailFormKey,
                        child: Column(
                          children: [
                            AppPillTextField(
                              controller: _emailController,
                              hintText: tr(ref, 'Email'),
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.email,
                                AutofillHints.username,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return tr(ref, 'Email is required');
                                }
                                final trimmed = v.trim();
                                final emailRegex = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                );
                                if (!emailRegex.hasMatch(trimmed)) {
                                  return tr(
                                    ref,
                                    'Please enter a valid email address',
                                  );
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            AppPillTextField(
                              controller: _passwordController,
                              hintText: tr(ref, 'Password'),
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) => _loginWithEmail(),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 21,
                                    color: isDark
                                        ? AppColors.organicIconDark
                                        : AppColors.organicIconLight,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return tr(ref, 'Password is required');
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () =>
                                    context.push(RouteNames.forgotPassword),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 2,
                                  ),
                                  child: Text(
                                    tr(ref, 'Forgot Password?'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
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

                            const SizedBox(height: 14),

                            AppGradientButton(
                              label: tr(ref, 'Sign In with Email'),
                              isLoading: _isEmailLoading,
                              onPressed: isAnyLoading
                                  ? () {}
                                  : () => _loginWithEmail(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Bottom Register Option
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tr(ref, "Don't have an account? "),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFFB0C4AF)
                                  : const Color(0xFF1E2B1F),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push(RouteNames.register);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                tr(ref, 'Sign Up'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 4. EULA & TERMS & PRIVACY POLICY (MANDATORY FOR PLAY STORE / APP STORE COMPLIANCE)
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
                              height: 1.45,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.inkSoft,
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
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.organicActionLinkDark
                                      : AppColors.organicActionLink,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '. We maintain a zero-tolerance policy against objectionable content and abusive users.',
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
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
