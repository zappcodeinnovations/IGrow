import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/app_gradient_button.dart';
import '../../../core/widgets/app_pill_text_field.dart';
import '../../../data/models/user_model.dart';
import '../providers/auth_provider.dart';

/// Modal dialog shown after social login when the user has incomplete profile details.
///
/// Prompts for Phone Number, State, and District.
/// Features a "Skip" button and redirects directly to the appropriate profile page.
class CompleteSocialProfileDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const CompleteSocialProfileDialog({
    super.key,
    required this.user,
  });

  /// Static helper to display the dialog
  static Future<void> show(BuildContext context, UserModel user) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompleteSocialProfileDialog(user: user),
    );
  }

  @override
  ConsumerState<CompleteSocialProfileDialog> createState() =>
      _CompleteSocialProfileDialogState();
}

class _CompleteSocialProfileDialogState
    extends ConsumerState<CompleteSocialProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _stateController;
  late final TextEditingController _districtController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user.phone);
    _stateController =
        TextEditingController(text: widget.user.locationState ?? '');
    _districtController =
        TextEditingController(text: widget.user.locationDistrict ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _navigateToProfile() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    final destination = widget.user.isFarmer
        ? RouteNames.farmerProfile
        : RouteNames.instructorProfile;
    context.go(destination);
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = _phoneController.text.trim();
    final state = _stateController.text.trim();
    final district = _districtController.text.trim();

    setState(() => _isSaving = true);

    try {
      final request = PatchedUserProfileRequest(
        phoneNumber: phone.isNotEmpty ? phone : null,
        locationState: state.isNotEmpty ? state : null,
        locationDistrict: district.isNotEmpty ? district : null,
      );

      await ref.read(authProvider.notifier).updateProfile(request);

      if (mounted) {
        AppToast.show(context, tr(ref, 'Profile updated successfully!'));
        _navigateToProfile();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          tr(ref, 'Failed to update details. You can update them in your profile.'),
          isError: true,
        );
        _navigateToProfile();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2822) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? AppColors.lineDark : AppColors.organicBorderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top organic icon badge
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.primaryGreen.withOpacity(0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_pin_circle_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  tr(ref, 'Complete Your Profile'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.greenDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  tr(
                    ref,
                    'Please share your phone number and location so instructors and peers can connect with you.',
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.organicSubtitleDark
                        : AppColors.organicSubtitleGreen,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                // Phone Field
                AppPillTextField(
                  controller: _phoneController,
                  hintText: tr(ref, 'Phone Number (10 digits)'),
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final trimmed = (value ?? '').trim();
                    if (trimmed.isNotEmpty &&
                        trimmed.replaceAll(RegExp(r'\D'), '').length < 10) {
                      return tr(ref, 'Enter a valid 10-digit phone number');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // State Field
                AppPillTextField(
                  controller: _stateController,
                  hintText: tr(ref, 'State (e.g. Maharashtra)'),
                  prefixIcon: Icons.map_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // District Field
                AppPillTextField(
                  controller: _districtController,
                  hintText: tr(ref, 'District / City (e.g. Pune)'),
                  prefixIcon: Icons.location_city_rounded,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isSaving) {
                      _saveAndContinue();
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Primary Action Button: Save & Continue
                AppGradientButton(
                  label: tr(ref, 'Save & Continue'),
                  isLoading: _isSaving,
                  onPressed: _isSaving ? () {} : () => _saveAndContinue(),
                ),
                const SizedBox(height: 12),

                // Secondary Action: Skip for now
                TextButton(
                  onPressed: _isSaving ? null : _navigateToProfile,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    tr(ref, 'Skip for Now'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.organicSubtitleDark
                          : AppColors.organicSubtitleGreen,
                    ),
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
