import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_gradient_button.dart';
import '../../../core/widgets/organic_background.dart';
import '../../../data/models/user_role.dart';

/// Role picker screen — Choice between Student / Farmer vs Instructor / Educator.
///
/// Features:
/// - Organic nature background with soft watercolor waves and botanical accents.
/// - Matches login screen styling with AMOLED pure black dark mode support.
/// - Translates dynamically using [tr(ref, ...)].
/// - Continues directly to LanguageSelectionScreen with the chosen role.
class ChooseRoleScreen extends ConsumerStatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  ConsumerState<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends ConsumerState<ChooseRoleScreen> {
  UserRole _selectedRole = UserRole.farmer;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OrganicBackground(
      child: SafeArea(
        child: ResponsiveContentConstraint(
          maxWidth: 500,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Headline
                Text(
                  tr(ref, 'Choose Your Role'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.organicHeadingDark
                        : AppColors.organicHeadingGreen,
                    height: 1.15,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  tr(ref, 'Select whether you want to learn or teach on iAgrow.'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.organicSubtitleDark
                        : AppColors.organicSubtitleGreen,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 32),

                // 1. Student / Learner Card
                _RoleCard(
                  title: tr(ref, 'Student / Learner'),
                  description: tr(
                    ref,
                    'Access agricultural courses, ebooks, community hubs, and expert guidance.',
                  ),
                  icon: Icons.school_rounded,
                  isSelected: _selectedRole == UserRole.farmer,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedRole = UserRole.farmer),
                ),

                const SizedBox(height: 16),

                // 2. Instructor / Educator Card
                _RoleCard(
                  title: tr(ref, 'Instructor / Educator'),
                  description: tr(
                    ref,
                    'Publish courses, manage student communities, upload guides, and track analytics.',
                  ),
                  icon: Icons.psychology_rounded,
                  isSelected: _selectedRole == UserRole.instructor,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedRole = UserRole.instructor),
                ),

                const SizedBox(height: 14),

                Text(
                  tr(ref, 'You can switch roles anytime from your profile.'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : AppColors.inkSoft,
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: AppGradientButton(
                    label: tr(ref, 'Continue'),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('selected_auth_role', _selectedRole.name);
                      if (context.mounted) {
                        context.go(
                          '${RouteNames.login}?role=${_selectedRole.name}',
                        );
                      }
                    },
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
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF16251A) : const Color(0xFFE8F5E9))
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.lineDark : AppColors.lineLight),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : (isDark ? const Color(0xFF202026) : const Color(0xFFEBF3E8)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.primaryGreen),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : AppColors.inkSoft,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : (isDark ? AppColors.lineDark : AppColors.lineLight),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 15,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
