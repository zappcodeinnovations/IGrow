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

/// Slide 1: Brand presentation (IAGROW • LEARN • GROW • ACHIEVE)
class _FirstOnboardingSlide extends StatelessWidget {
  const _FirstOnboardingSlide();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Brand Emblem
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E3524), const Color(0xFF142419)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.eco_rounded,
                size: 56,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Main Title
          Text(
            'IGROW',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: isDark ? AppColors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 6),

          // Tagline Badge
          Text(
            'LEARN • GROW • ACHIEVE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
            ),
          ),

          const SizedBox(height: 36),

          // Hero Preview Card
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B2E21), const Color(0xFF132218)]
                    : [const Color(0xFFEAF5EC), const Color(0xFFD6EDDC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? AppColors.lineDark
                    : AppColors.primaryGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.agriculture_rounded,
                  size: 72,
                  color: AppColors.primaryGreen.withValues(alpha: 0.35),
                ),
                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF132218) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Empowering Modern Farmers',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.white : AppColors.inkDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Description
          Text(
            'Knowledge for every farm. Opportunity for every learner.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: isDark ? AppColors.inkSoft : AppColors.inkSoft,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Slide 2: EdTech value proposition (Grow better. Learn smarter.)
class _SecondOnboardingSlide extends StatelessWidget {
  const _SecondOnboardingSlide();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Overline / Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'THE FUTURE OF FARM LEARNING',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: isDark ? AppColors.greenLight : AppColors.primaryGreen,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Hero Preview Card
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B2E21), const Color(0xFF132218)]
                    : [const Color(0xFFEAF5EC), const Color(0xFFD6EDDC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? AppColors.lineDark
                    : AppColors.primaryGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 72,
                  color: AppColors.primaryGreen.withValues(alpha: 0.35),
                ),
                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF132218) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_lesson_rounded,
                          size: 16,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Expert Courses & Multi-language Support',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.white : AppColors.inkDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Headline
          Text(
            'Grow better.\nLearn smarter.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.25,
              color: isDark ? AppColors.white : AppColors.inkDark,
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Practical farming courses taught by trusted agriculture experts, in your language.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: isDark ? AppColors.inkSoft : AppColors.inkSoft,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
