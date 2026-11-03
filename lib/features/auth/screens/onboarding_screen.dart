import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/canopy_gradient.dart';
import '../../../core/widgets/app_gradient_button.dart';
import '../../../core/router/route_names.dart';

/// Two-page onboarding screen inspired by modern EdTech design,
/// styled with IGrow's native design system and colors.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    if (mounted) {
      context.go(RouteNames.languageSelection);
    }
  }

  void _next() {
    if (_currentPage < 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skip() {
    _finishOnboarding();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentPage == 1;

    return Scaffold(
      body: CanopyGradient(
        child: SafeArea(
          child: Column(
            children: [
              // Top action bar (Skip button)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white.withValues(alpha: 0.7) : AppColors.inkSoft,
                      ),
                    ),
                  ),
                ),
              ),

              // 2-page carousel
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: const [
                    _FirstOnboardingSlide(),
                    _SecondOnboardingSlide(),
                  ],
                ),
              ),

              // Bottom control area: indicators, primary button, sign-in link
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 2,
                      effect: ExpandingDotsEffect(
                        activeDotColor: AppColors.primaryGreen,
                        dotColor: isDark
                            ? AppColors.white.withValues(alpha: 0.2)
                            : AppColors.lineLight,
                        dotHeight: 7,
                        dotWidth: 7,
                        expansionFactor: 3,
                        spacing: 6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppGradientButton(
                      label: 'Get started',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
                    const SizedBox(height: 14),
                    if (isLast)
                      GestureDetector(
                        onTap: () => context.go(RouteNames.login),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: isDark ? AppColors.inkSoft : AppColors.inkSoft,
                              ),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Sign in',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slide 1: Brand presentation (IGROW • LEARN • GROW • ACHIEVE)
class _FirstOnboardingSlide extends StatelessWidget {
  const _FirstOnboardingSlide();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // Brand Emblem with subtle glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E3A27), const Color(0xFF13281B)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.22),
                  blurRadius: 36,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.eco_rounded,
                size: 64,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Main Title
          Text(
            'IGROW',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.0,
              color: isDark ? AppColors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 8),

          // Tagline
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'LEARN • GROW • ACHIEVE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Description
          Text(
            'Knowledge for every farm.\nOpportunity for every learner.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: isDark ? AppColors.white.withValues(alpha: 0.75) : AppColors.inkSoft,
            ),
          ),

          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

/// Slide 2: Value proposition (Grow better. Learn smarter.)
class _SecondOnboardingSlide extends StatelessWidget {
  const _SecondOnboardingSlide();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // Focal Feature Emblem
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E3A27), const Color(0xFF13281B)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.22),
                  blurRadius: 36,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.auto_stories_rounded,
                size: 58,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Overline / Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'THE FUTURE OF FARM LEARNING',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Headline
          Text(
            'Grow better.\nLearn smarter.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.2,
              color: isDark ? AppColors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 14),

          // Subtitle
          Text(
            'Practical farming courses taught by trusted agriculture experts, in your native language.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: isDark ? AppColors.white.withValues(alpha: 0.75) : AppColors.inkSoft,
            ),
          ),

          const Spacer(flex: 4),
        ],
      ),
    );
  }
}
