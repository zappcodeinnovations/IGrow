import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
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

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _generateSecureRandomPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*';
    final rnd = Random.secure();
    return List.generate(14, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Determine target role from saved preference, defaulting to farmer/student
    UserRole targetRole = UserRole.farmer;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString('selected_auth_role');
      if (savedRole == 'instructor') {
        targetRole = UserRole.instructor;
      }
    } catch (_) {}

    final generatedPassword = _generateSecureRandomPassword();

    final success = await ref
        .read(authProvider.notifier)
        .completePhoneProfile(
          phoneNumber: widget.phoneNumber,
          verificationToken: widget.verificationToken,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: generatedPassword,
          role: targetRole,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        TextInput.finishAutofillContext();
        Navigator.of(context).pop();
        widget.onCompleted();
      } else {
        final err =
            ref.read(authProvider).error ?? 'Failed to complete profile.';
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
          child: AutofillGroup(
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
                    tr(
                      ref,
                      'Phone verified! Just a few quick details to personalize your account.',
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: isDark ? Colors.white70 : AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verified Phone Number Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF142418)
                          : const Color(0xFFEBF6EC),
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
                    autofillHints: const [AutofillHints.name],
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: '${tr(ref, 'Full Name')} *',
                      hintText: tr(ref, 'e.g. Ramesh Patil'),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF162319)
                          : const Color(0xFFF7FAF6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF2C3E31)
                              : const Color(0xFFE2EBE0),
                        ),
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
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: '${tr(ref, 'Email Address')} *',
                      hintText: tr(ref, 'e.g. ramesh@gmail.com'),
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF162319)
                          : const Color(0xFFF7FAF6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF2C3E31)
                              : const Color(0xFFE2EBE0),
                        ),
                      ),
                    ),
                    validator: (val) {
                      final email = val?.trim() ?? '';
                      if (email.isEmpty) {
                        return tr(ref, 'Email address is required');
                      }
                      if (RegExp(r'[A-Z]').hasMatch(email)) {
                        return tr(
                          ref,
                          'Email must contain lowercase letters only',
                        );
                      }
                      final emailRegex = RegExp(
                        r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(email)) {
                        return tr(ref, 'Please enter a valid email address');
                      }
                      return null;
                    },
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
      ),
    );
  }
}
