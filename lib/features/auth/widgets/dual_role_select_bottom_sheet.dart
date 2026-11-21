import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_role.dart';

/// Bottom sheet dialog prompting a user with multiple roles to select their active mode.
class DualRoleSelectBottomSheet extends ConsumerWidget {
  const DualRoleSelectBottomSheet({
    super.key,
    required this.availableRoles,
    required this.onRoleSelected,
  });

  final List<UserRole> availableRoles;
  final ValueChanged<UserRole> onRoleSelected;

  static Future<UserRole?> show(
    BuildContext context, {
    List<UserRole>? availableRoles,
  }) {
    return showModalBottomSheet<UserRole>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DualRoleSelectBottomSheet(
        availableRoles: availableRoles ?? const [UserRole.farmer, UserRole.instructor],
        onRoleSelected: (role) => Navigator.of(ctx).pop(role),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2822) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                tr(ref, 'Login as Student or Instructor?'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.inkDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr(ref, 'Choose how you want to continue (you can switch anytime):'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppColors.inkSoft,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // Role 1: Student
              _buildRoleOptionCard(
                context: context,
                ref: ref,
                isDark: isDark,
                title: tr(ref, 'Student Mode 🎓'),
                subtitle: tr(ref, 'Learn, enroll in courses & read expert agricultural e-books.'),
                icon: Icons.school_rounded,
                accentColor: AppColors.primaryGreen,
                onTap: () => onRoleSelected(UserRole.farmer),
              ),
              const SizedBox(height: 10),

              // Role 2: Instructor
              _buildRoleOptionCard(
                context: context,
                ref: ref,
                isDark: isDark,
                title: tr(ref, 'Instructor Mode 👨‍🏫'),
                subtitle: tr(ref, 'Manage courses, upload e-books, track revenue & students.'),
                icon: Icons.menu_book_rounded,
                accentColor: const Color(0xFFD97706),
                onTap: () => onRoleSelected(UserRole.instructor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOptionCard({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141F17) : const Color(0xFFF7FAF6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2C3E31) : const Color(0xFFE2EBE0),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : AppColors.inkSoft,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: isDark ? Colors.white38 : AppColors.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
