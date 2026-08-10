import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/canopy_gradient.dart';
import '../../../core/router/route_names.dart';
import '../providers/auth_provider.dart';

/// Splash screen with canopy gradient and auto-navigation.
///
/// Shows the app logo/brand, checks for an existing session,
/// and navigates to onboarding or the correct home shell.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Trigger session check after first frame to avoid build phase conflicts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkSession();
    });

    // Minimum delay for the splash screen animation.
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _minDelayPassed = true;
        _navigateIfNeeded();
      }
    });
  }

  bool _minDelayPassed = false;

  Future<void> _navigateIfNeeded() async {
    if (!_minDelayPassed) return;

    final authState = ref.read(authProvider);
    
    // Wait until the auth state is determined
    if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
      return;
    }

    if (authState.isAuthenticated) {
      // Go to the correct home based on role (router handles this via redirect).
      // We don't necessarily need to call context.go('/') here if the router does it, 
      // but doing it explicitly guarantees the transition if the router didn't catch the splash location.
      context.go('/');
    } else {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
      if (mounted) {
        if (hasCompletedOnboarding) {
          context.go(RouteNames.login);
        } else {
          context.go(RouteNames.onboarding);
        }
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
    // Listen for auth state changes so we can navigate as soon as checkSession finishes
    // (if the minimum splash delay has already passed).
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status != AuthStatus.initial && next.status != AuthStatus.loading) {
        _navigateIfNeeded();
      }
    });

    return Scaffold(
      body: CanopyGradient(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App logo image.
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: AppColors.greenShadow(
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                      opacity: 0.3,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.eco_rounded, size: 80, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'IGrow',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.greenDark,),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn • Grow • Achieve',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
