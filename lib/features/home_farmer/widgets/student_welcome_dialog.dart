import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/complete_phone_profile_bottom_sheet.dart';
import '../../auth/widgets/complete_social_profile_dialog.dart';
import 'welcome_diorama_asset.dart';

/// Welcome promotional popup for students highlighting free courses and free e-books.
class StudentWelcomeDialog extends ConsumerWidget {
  const StudentWelcomeDialog({super.key});

  static const String _kWelcomeDismissedKey =
      'has_seen_student_free_welcome_popup';

  /// Checks if the popup should be shown (first time student lands on home).
  /// If the complete profile dialog or sheet is open or profile is incomplete,
  /// waits until it is completed and dismissed, then waits 1 second before showing.
  static Future<void> checkAndShow(
    BuildContext context, {
    String? userId,
    UserModel? user,
    required WidgetRef ref,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? user?.id ?? user?.email;
    final key = effectiveUserId != null
        ? '${_kWelcomeDismissedKey}_$effectiveUserId'
        : _kWelcomeDismissedKey;
    final hasSeen = prefs.getBool(key) ?? false;

    if (hasSeen) return;

    // Give a brief delay after landing on home screen before welcoming
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!context.mounted) return;

    // Re-verify if already shown in the interim
    final seenAfterWait = prefs.getBool(key) ?? false;
    if (!seenAfterWait) {
      await prefs.setBool(key, true);
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => const StudentWelcomeDialog(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Floating Pop-up Card
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A), // Deep Slate
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.65),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.18),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Text: Congratulations & Free Badge
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFEF08A),
                              Color(0xFFFBBF24),
                              Color(0xFFF59E0B),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            tr(ref, '🎉 Congratulations!').toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tr(ref, '100% Free Courses & E-Books Unlocked'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Field Banner Image
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF10B981,
                                ).withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/banners/free_courses_field.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.memory(
                                kFarmerWelcomeDioramaBytes,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/banners/farmer_welcome_diorama.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF1B4D2E),
                                    child: const Center(
                                      child: Icon(
                                        Icons.agriculture_rounded,
                                        size: 64,
                                        color: Color(0xFF34D399),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Vibrant Pill Action Button (Matches the Yellow-Orange Gradient in Ref Image 2)
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFDE047), // Vibrant yellow
                                Color(0xFFF59E0B), // Warm amber
                                Color(0xFFF43F5E), // Rose coral accent
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFF59E0B,
                                ).withOpacity(0.45),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: () {
                                Navigator.of(context).pop();
                                // Navigate straight to Explore page filtered for Free
                                context.go('${RouteNames.explore}?price=free');
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tr(ref, 'Unveil Free Courses'),
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bottom Circular Dismiss / Close Button (Exact match with reference image)
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
