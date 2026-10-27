import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/canopy_gradient.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/router/route_names.dart';

/// Three-page onboarding screen with illustrations, dot indicators, and skip/next.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.agriculture_rounded,
      title: 'Learn Modern Farming',
      description:
          'Access expert-led video courses on crop management, organic farming, livestock care, and more.',
      color: AppColors.primaryGreen,
    ),
    _OnboardingPage(
      icon: Icons.store_rounded,
      title: 'Buy & Sell Products',
      description:
          'Find seeds, fertilizers, equipment, and organic products from trusted sellers across India.',
      color: AppColors.accentOrange,
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      title: 'Join the Community',
      description:
          'Connect with fellow farmers, ask experts, share knowledge, and stay updated on govt schemes.',
      color: AppColors.skyBlue,
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    if (mounted) {
      context.go(RouteNames.languageSelection);
    }
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
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
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: CanopyGradient(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button.
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.inkSoft,),
                    ),
                  ),
                ),
              ),
              // Pages.
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _OnboardingContent(page: page);
                  },
                ),
              ),
              // Indicators & button.
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: AppColors.primaryGreen,
                        dotColor: AppColors.lineLight,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3,
                        spacing: 6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AppButton(
                      label: isLast ? 'Get Started' : 'Next',
                      onPressed: _next,
                      icon: isLast ? Icons.arrow_forward_rounded : null,
                    ),
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

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
