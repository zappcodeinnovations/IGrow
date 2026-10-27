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

/// Language selection screen — grid of language options.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key, this.selectedRole});

  final String? selectedRole;

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}
class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  String _selected = 'English';

  static const _languages = [
    _Language('English', 'English', 'A', 'Universal / Official'),
    _Language('Hindi', 'हिन्दी', 'अ', 'राष्ट्रीय भाषा'),
    _Language('Marathi', 'मराठी', 'म', 'प्रादेशिक भाषा'),
  ];

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
                Text(
                  tr(ref, 'Choose Your\nLanguage'),
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
                Text(
                  tr(ref, 'Select the language you\'re most comfortable with.'),
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
                
                // 3 Exclusive Language Cards
                ..._languages.map((lang) {
                  final isSelected = lang.codeName.toLowerCase() == _selected.toLowerCase() ||
                      lang.nativeName == _selected;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _LanguageCard(
                      language: lang,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () async {
                        setState(() => _selected = lang.codeName);
                        await ref.read(languageProvider.notifier).setLanguage(lang.codeName);
                      },
                    ),
                  );
                }),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: AppGradientButton(
                    label: tr(ref, 'Continue'),
                    onPressed: () async {
                      await ref.read(languageProvider.notifier).setLanguage(_selected);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('has_selected_language', true);
                      if (context.mounted) {
                        context.go(RouteNames.chooseRole);
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
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : (isDark ? const Color(0xFF202026) : const Color(0xFFEBF3E8)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  language.glyph,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : AppColors.primaryGreen),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language.nativeName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                      if (language.codeName != language.nativeName) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${language.codeName})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    language.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : AppColors.inkSoft,
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
