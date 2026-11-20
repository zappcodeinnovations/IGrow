import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

/// Modal bottom sheet for an existing student becoming an instructor.
/// Prompts for their instructor display name and phone number (if missing or to confirm).
class BecomeInstructorBottomSheet extends ConsumerStatefulWidget {
  const BecomeInstructorBottomSheet({
    super.key,
    required this.onSuccess,
  });

  final VoidCallback onSuccess;

  static Future<bool?> show(BuildContext context, {required VoidCallback onSuccess}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: BecomeInstructorBottomSheet(onSuccess: onSuccess),
      ),
    );
  }

  @override
  ConsumerState<BecomeInstructorBottomSheet> createState() =>
      _BecomeInstructorBottomSheetState();
}

class _BecomeInstructorBottomSheetState
    extends ConsumerState<BecomeInstructorBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  bool _isLoading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(
      text: (user?.phone ?? '').replaceAll('+91', '').trim(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      AppToast.show(
        context,
        tr(ref, 'Please enter a valid 10-digit mobile number'),
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      // 1. Update basic profile with instructor name & phone number
      await ref.read(authProvider.notifier).updateProfile(
            PatchedUserProfileRequest(
              fullName: name,
              phoneNumber: phone.startsWith('+') ? phone : '+91$phone',
            ),
          );

      // 2. Call dedicated creator onboarding endpoint to provision instructor profile and update claims
      await ref.read(authProvider.notifier).becomeInstructor();

      final successMsg = tr(ref, 'Switched to Instructor Mode! 👨‍🏫');

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true);
        AppToast.show(context, successMsg);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        final err = e.toString().replaceAll('Exception: ', '').trim();
        setState(() => _isLoading = false);
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
            autovalidateMode: _autovalidateMode,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_rounded, color: Color(0xFFD97706), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr(ref, 'Become an Instructor 👨‍🏫'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.inkDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr(ref, 'Start sharing your knowledge and courses.'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: isDark ? Colors.white60 : AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  tr(ref, 'Confirm your teaching name and contact number for your instructor profile:'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: tr(ref, 'Instructor / Display Name *'),
                    hintText: tr(ref, 'e.g. Dr. Ramesh Patil'),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF162319) : const Color(0xFFF7FAF6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF2C3E31) : const Color(0xFFE2EBE0),
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return tr(ref, 'Please enter your instructor name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: tr(ref, 'Contact Mobile Number *'),
                    hintText: tr(ref, '10-digit mobile number'),
                    prefixText: '+91 ',
                    prefixIcon: const Icon(Icons.phone_android_rounded),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF162319) : const Color(0xFFF7FAF6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF2C3E31) : const Color(0xFFE2EBE0),
                      ),
                    ),
                  ),
                  validator: (val) {
                    final clean = (val ?? '').replaceAll(RegExp(r'[^\d]'), '').trim();
                    if (clean.length != 10) {
                      return tr(ref, 'Please enter a valid 10-digit mobile number');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                AppButton(
                  label: tr(ref, 'Confirm & Enter Instructor Dashboard'),
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
}
