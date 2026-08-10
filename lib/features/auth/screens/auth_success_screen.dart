import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/canopy_gradient.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/user_role.dart';
import '../providers/auth_provider.dart';

/// Success screen after login/registration, with confetti-style celebration.
class AuthSuccessScreen extends ConsumerWidget {
  const AuthSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final roleName = user?.activeRole.label ?? 'User';

    return Scaffold(
      body: CanopyGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Success checkmark
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.greenDark,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: AppColors.greenShadow(
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                        opacity: 0.3,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 60,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'You\'re All Set! 🎉',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.greenDark,),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome aboard as $roleName.\nLet\'s start your agriculture journey!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                AppButton(
                  label: 'Go to Dashboard',
                  onPressed: () {
                    final role = user?.activeRole ?? UserRole.farmer;
                    if (role == UserRole.instructor) {
                      context.go('/instructor/home');
                    } else {
                      context.go('/farmer/home');
                    }
                  },
                  icon: Icons.arrow_forward_rounded,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
