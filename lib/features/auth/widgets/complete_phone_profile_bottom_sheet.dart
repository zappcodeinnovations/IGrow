import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/user_role.dart';
import '../providers/auth_provider.dart';

/// Modal bottom sheet for new WhatsApp phone users to complete profile details.
class CompletePhoneProfileBottomSheet extends ConsumerStatefulWidget {
  const CompletePhoneProfileBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.verificationToken,
    required this.onCompleted,
  });

  final String phoneNumber;
  final String verificationToken;
  final VoidCallback onCompleted;

  /// Whether a CompletePhoneProfileBottomSheet is currently visible on screen.
  static bool isOpen = false;

  static Future<void> show(
    BuildContext context, {
    required String phoneNumber,
    required String verificationToken,
    required VoidCallback onCompleted,
  }) async {
    isOpen = true;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: CompletePhoneProfileBottomSheet(
            phoneNumber: phoneNumber,
            verificationToken: verificationToken,
            onCompleted: onCompleted,
          ),
        ),
      );
    } finally {
      isOpen = false;
    }
  }

  @override
  ConsumerState<CompletePhoneProfileBottomSheet> createState() =>
      _CompletePhoneProfileBottomSheetState();
}

class _CompletePhoneProfileBottomSheetState
    extends ConsumerState<CompletePhoneProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.farmer;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).completePhoneProfile(
          phoneNumber: widget.phoneNumber,
          verificationToken: widget.verificationToken,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        widget.onCompleted();
      } else {
        final err = ref.read(authProvider).error ?? 'Failed to complete profile.';
        AppToast.show(context, err, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  tr(ref, 'Complete Your Profile'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.inkDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr(ref, 'Phone verified! Just a few quick details to personalize your account.'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 20),

                // Verified Phone Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF142418) : const Color(0xFFEBF6EC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tr(ref, 'Verified Mobile:'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : AppColors.inkDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.phoneNumber,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${tr(ref, 'Full Name')} *',
                    hintText: tr(ref, 'e.g. Ramesh Patil'),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF162319) : const Color(0xFFF7FAF6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF2C3E31) : const Color(0xFFE2EBE0)),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return tr(ref, 'Please enter your full name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email Address (Mandatory)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '${tr(ref, 'Email Address')} *',
                    hintText: tr(ref, 'e.g. ramesh@gmail.com'),
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF162319) : const Color(0xFFF7FAF6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF2C3E31) : const Color(0xFFE2EBE0)),
                    ),
                  ),
                  validator: (val) {
                    final email = val?.trim() ?? '';
                    if (email.isEmpty) {
                      return tr(ref, 'Email address is required');
                    }
                    if (RegExp(r'[A-Z]').hasMatch(email)) {
                      return tr(ref, 'Email must contain lowercase letters only');
                    }
                    final emailRegex = RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$');
                    if (!emailRegex.hasMatch(email)) {
                      return tr(ref, 'Please enter a valid email address');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '${tr(ref, 'Create Password')} *',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF162319) : const Color(0xFFF7FAF6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF2C3E31) : const Color(0xFFE2EBE0)),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return tr(ref, 'Password must be at least 6 characters');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Role Selection
                Text(
                  tr(ref, 'Select Your Role'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.inkDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        isDark: isDark,
                        title: tr(ref, 'Student 🎓'),
                        subtitle: tr(ref, 'Learn & study'),
                        role: UserRole.farmer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoleCard(
                        isDark: isDark,
                        title: tr(ref, 'Instructor 👨‍🏫'),
                        subtitle: tr(ref, 'Teach & create'),
                        role: UserRole.instructor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                AppButton(
                  label: tr(ref, 'Complete & Continue'),
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required UserRole role,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF162B1D) : const Color(0xFFEBF6EC))
              : (isDark ? const Color(0xFF141F17) : const Color(0xFFF7FAF6)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? const Color(0xFF2C3E31) : const Color(0xFFE2EBE0)),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primaryGreen
                    : (isDark ? Colors.white : AppColors.inkDark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: isDark ? Colors.white60 : AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
