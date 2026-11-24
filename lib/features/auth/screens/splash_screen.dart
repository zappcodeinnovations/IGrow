import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/canopy_gradient.dart';
import '../../../core/router/route_names.dart';
import '../../../core/services/app_config_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/version_service.dart';
import '../../../core/widgets/app_update_dialog.dart';
import '../../../data/models/user_role.dart';
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

  bool _minDelayPassed = false;
  bool _versionCheckDone = false;
  bool _isUpdateDialogShowing = false;
  VersionCheckResult? _versionResult;

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

    // Trigger session check and version check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appConfigProvider.notifier).loadConfig();
      ref.read(authProvider.notifier).checkSession();
      _checkAppVersion();
    });

    // Delay for the welcome screen so user can read it (3 seconds).
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _minDelayPassed = true;
        _navigateIfNeeded();
      }
    });
  }

  Future<void> _checkAppVersion() async {
    try {
      _versionResult = await VersionService.checkVersion();
    } catch (e) {
      debugPrint('⚠️ [SplashScreen] Version check error: $e');
    } finally {
      if (mounted) {
        _versionCheckDone = true;
        _navigateIfNeeded();
      }
    }
  }

  Future<void> _navigateIfNeeded() async {
    if (!_minDelayPassed || !_versionCheckDone) return;
    if (_isUpdateDialogShowing) return;

    // If update is required, show the mandatory update dialog and stop navigation
    if (_versionResult != null && _versionResult!.isUpdateRequired) {
      _isUpdateDialogShowing = true;
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.75),
          builder: (_) => AppUpdateDialog(
            currentVersion: _versionResult!.currentVersion,
            newVersion: _versionResult!.config?.latestVersion ?? '',
            storeUrl: _versionResult!.config?.storeUrl ?? '',
            title: _versionResult!.config?.updateTitle,
            message: _versionResult!.config?.updateMessage,
          ),
        );
      }
      return;
    }

    final authState = ref.read(authProvider);
    
    // Wait until the auth state is determined
    if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
      return;
    }

    if (authState.isAuthenticated) {
      final pendingRoute = NotificationService.pendingLaunchRoute;
      if (pendingRoute != null && pendingRoute.isNotEmpty) {
        NotificationService.pendingLaunchRoute = null;
        debugPrint('🚀 [SplashScreen] Fulfilling pending notification launch route: $pendingRoute');

        // Check if pending route is role-specific and needs conversion for instructor
        final role = authState.user?.activeRole;
        String resolvedRoute = pendingRoute;
        if (role == UserRole.instructor || role == UserRole.admin) {
          if (resolvedRoute.startsWith('/farmer/community')) {
            resolvedRoute = resolvedRoute.replaceFirst('/farmer/community', RouteNames.instructorCommunity);
          } else if (resolvedRoute == '/community' || resolvedRoute.startsWith('/community?')) {
            resolvedRoute = resolvedRoute.replaceFirst('/community', RouteNames.instructorCommunity);
          } else if (resolvedRoute.startsWith('/farmer/course')) {
            resolvedRoute = RouteNames.instructorUploads;
          }
        } else {
          if (resolvedRoute.startsWith('/instructor/community')) {
            resolvedRoute = resolvedRoute.replaceFirst('/instructor/community', RouteNames.farmerCommunity);
          }
        }
        context.go(resolvedRoute);
        return;
      }
      // Go to the correct home based on role (router handles this via redirect).
      context.go('/');
    } else {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedInitialSetup = prefs.getBool('has_completed_initial_setup') ?? 
          (prefs.getBool('has_selected_language') ?? false);
      if (mounted) {
        if (hasCompletedInitialSetup) {
          final savedRole = prefs.getString('selected_auth_role') ?? 'farmer';
          if (savedRole == 'instructor') {
            context.go(RouteNames.instructorHome);
          } else {
            context.go(RouteNames.farmerHome);
          }
        } else {
          context.go(RouteNames.languageSelection);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(36),
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
                        const Icon(Icons.eco_rounded, size: 70, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Welcome to iAgrow',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? Colors.white : AppColors.greenDark,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Empowering Agriculture with Knowledge',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.greenLight : const Color(0xFF2E6E34),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Learn • Grow • Achieve',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : AppColors.inkSoft,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
