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
import '../providers/auth_provider.dart';

/// Unified Language & Role Selection screen.
///
/// Presents language selection and role selection on the same page before
/// routing directly to the login page.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key, this.selectedRole});

  final String? selectedRole;

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  String? _selectedLanguage;
  UserRole _selectedRole = UserRole.farmer;
  bool _isLoading = false;

  static const _languages = [
    _Language('English', 'English', 'A', 'Universal / Official'),
    _Language('Hindi', 'हिन्दी', 'अ', 'राष्ट्रीय भाषा'),
    _Language('Marathi', 'मराठी', 'म', 'प्रादेशिक भाषा'),
  ];

  static String _codeToName(String code) {
    final lower = code.toLowerCase().trim();
    if (lower == 'hi' || lower == 'hindi') return 'Hindi';
    if (lower == 'mr' || lower == 'marathi') return 'Marathi';
    return 'English';
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeCode = ref.read(languageProvider);
      final savedRole = widget.selectedRole ??
          prefs.getString('selected_auth_role') ??
          prefs.getString('active_user_role');

      if (mounted) {
        setState(() {
          _selectedLanguage = _codeToName(activeCode);
          if (savedRole != null && savedRole.toLowerCase() == 'instructor') {
            _selectedRole = UserRole.instructor;
          } else {
            _selectedRole = UserRole.farmer;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _onContinue() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final chosenLang = _selectedLanguage ?? _codeToName(ref.read(languageProvider));
      await ref.read(languageProvider.notifier).setLanguage(chosenLang);

      // Persist onboarding & selection choices
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);
      await prefs.setBool('has_selected_language', true);
      await prefs.setBool('has_completed_initial_setup', true);
      await prefs.setString('selected_auth_role', _selectedRole.name);
      await prefs.setString('active_user_role', _selectedRole.name);

      ref.read(authProvider.notifier).setOnboardingRole(_selectedRole);

      if (mounted) {
        if (_selectedRole == UserRole.instructor) {
          context.go(RouteNames.instructorHome);
        } else {
          context.go(RouteNames.farmerHome);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OrganicBackground(
      child: SafeArea(
        child: ResponsiveContentConstraint(
          maxWidth: 500,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // App logo & welcome badge
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: AppColors.greenShadow(
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                                opacity: 0.15,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.eco_rounded, size: 24, color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'iAgrow',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.white : AppColors.primaryGreen,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Section 1 Header: Language Selection
                      Text(
                        tr(ref, 'Choose Your Language'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.organicHeadingDark
                              : AppColors.organicHeadingGreen,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Language Cards (compact)
                      ..._languages.map((lang) {
                        final activeLangName = _selectedLanguage ?? _codeToName(ref.watch(languageProvider));
                        final isSelected = lang.codeName.toLowerCase() == activeLangName.toLowerCase() ||
                            lang.nativeName == activeLangName;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LanguageCard(
                            language: lang,
                            isSelected: isSelected,
                            isDark: isDark,
                            onTap: () async {
                              setState(() => _selectedLanguage = lang.codeName);
                              await ref.read(languageProvider.notifier).setLanguage(lang.codeName);
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 18),

                      // Section 2 Header: Role Selection
                      Text(
                        tr(ref, 'Choose Your Role'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.organicHeadingDark
                              : AppColors.organicHeadingGreen,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Role Card 1: Student / Learner
                      _RoleCard(
                        title: tr(ref, 'Student / Learner'),
                        description: tr(
                          ref,
                          'Access courses, ebooks, community, and expert guidance.',
                        ),
                        icon: Icons.school_rounded,
                        isSelected: _selectedRole == UserRole.farmer,
                        isDark: isDark,
                        onTap: () => setState(() => _selectedRole = UserRole.farmer),
                      ),
                      const SizedBox(height: 8),

                      // Role Card 2: Instructor / Educator
                      _RoleCard(
                        title: tr(ref, 'Instructor / Educator'),
                        description: tr(
                          ref,
                          'Publish courses, guides, and share your agricultural expertise.',
                        ),
                        icon: Icons.psychology_rounded,
                        isSelected: _selectedRole == UserRole.instructor,
                        isDark: isDark,
                        onTap: () => setState(() => _selectedRole = UserRole.instructor),
                      ),

                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          tr(ref, 'You can switch roles anytime from your profile.'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white54 : AppColors.inkSoft,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // Bottom Continue Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: AppGradientButton(
                  label: tr(ref, 'Continue to iAgrow'),
                  isLoading: _isLoading,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Language {
  const _Language(this.codeName, this.nativeName, this.glyph, this.subtitle);
  final String codeName;
  final String nativeName;
  final String glyph;
  final String subtitle;
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final _Language language;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF16251A) : const Color(0xFFE8F5E9))
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.lineDark : AppColors.lineLight),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.12)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : (isDark ? const Color(0xFF202026) : const Color(0xFFEBF3E8)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  language.glyph,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : AppColors.primaryGreen),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language.nativeName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                      if (language.codeName != language.nativeName) ...[
                        const SizedBox(width: 5),
                        Text(
                          '(${language.codeName})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    language.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : (isDark ? AppColors.lineDark : AppColors.lineLight),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 13,
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF16251A) : const Color(0xFFE8F5E9))
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.lineDark : AppColors.lineLight),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.12)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : (isDark ? const Color(0xFF202026) : const Color(0xFFEBF3E8)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.primaryGreen),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : AppColors.inkSoft,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : (isDark ? AppColors.lineDark : AppColors.lineLight),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 13,
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
