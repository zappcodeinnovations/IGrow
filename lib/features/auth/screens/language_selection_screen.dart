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
    _Language('English', 'A', '🇬🇧'),
    _Language('हिन्दी', 'अ', '🇮🇳'),
    _Language('मराठी', 'अ', '🇮🇳'),
    _Language('தமிழ்', 'அ', '🇮🇳'),
    _Language('తెలుగు', 'అ', '🇮🇳'),
    _Language('ಕನ್ನಡ', 'ಅ', '🇮🇳'),
    _Language('বাংলা', 'অ', '🇮🇳'),
    _Language('ગુજરાતી', 'અ', '🇮🇳'),
    _Language('ਪੰਜਾਬੀ', 'ਅ', '🇮🇳'),
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
                const SizedBox(height: 28),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1,
                    ),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = lang.name == _selected;
                      return _LanguageCard(
                        language: lang,
                        isSelected: isSelected,
                        onTap: () async {
                          setState(() => _selected = lang.name);
                          await ref.read(languageProvider.notifier).setLanguage(lang.name);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: AppGradientButton(
                    label: tr(ref, 'Continue'),
                    onPressed: () async {
                      await ref.read(languageProvider.notifier).setLanguage(_selected);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('has_selected_language', true);
                      if (context.mounted) {
                        final role = widget.selectedRole ?? prefs.getString('selected_auth_role') ?? 'farmer';
                        context.go('${RouteNames.login}?role=$role');
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
  const _Language(this.name, this.script, this.flag);
  final String name;
  final String script;
  final String flag;
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final _Language language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF16251A) : const Color(0xFFE8F5E9))
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.lineDark : AppColors.lineLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              language.script,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primaryGreen
                    : (isDark ? Colors.white : AppColors.inkDark),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              language.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryGreen
                    : (isDark ? Colors.white70 : AppColors.inkSoft),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
