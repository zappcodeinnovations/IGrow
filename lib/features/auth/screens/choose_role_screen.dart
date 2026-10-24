import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/canopy_gradient.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/user_role.dart';

/// Role picker screen — Farmer vs Instructor selection cards.
///
/// The chosen role is passed as a query parameter to the login/register screen
/// and used to set the initial `activeRole` on the account.
class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CanopyGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'How will you\nuse iAgrow?',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'You can switch roles anytime from your profile.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 40),
                _RoleCard(
                  role: UserRole.farmer,
                  isSelected: _selectedRole == UserRole.farmer,
                  onTap: () => setState(() => _selectedRole = UserRole.farmer),
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  role: UserRole.instructor,
                  isSelected: _selectedRole == UserRole.instructor,
                  onTap: () =>
                      setState(() => _selectedRole = UserRole.instructor),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AppButton(
                    label: 'Continue',
                    onPressed: _selectedRole != null
                        ? () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('has_completed_onboarding', true);
                            if (context.mounted) {
                              context.go(
                                '${RouteNames.login}?role=${_selectedRole!.name}',
                              );
                            }
                          }
                        : null,
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
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
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : (isDark ? AppColors.cardDark : AppColors.white),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.lineDark : AppColors.lineLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? AppColors.greenShadow(
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  opacity: 0.25,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.2)
                    : AppColors.canopyStart,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                role.icon,
                size: 32,
                color: isSelected ? AppColors.white : AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.label,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: isSelected
                          ? AppColors.white
                          : (isDark ? AppColors.white : AppColors.inkDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isSelected
                          ? AppColors.white.withValues(alpha: 0.85)
                          : AppColors.inkSoft,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.white
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.white
                      : (isDark ? AppColors.lineDark : AppColors.lineLight),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppColors.primaryGreen,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
