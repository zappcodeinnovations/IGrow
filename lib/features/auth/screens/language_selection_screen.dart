import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/canopy_gradient.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/router/route_names.dart';

/// Language selection screen — grid of language options.
///
/// Currently UI-only (no actual i18n). Picking a language just proceeds
/// to the role selection screen.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
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
    return Scaffold(
      body: CanopyGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Choose Your\nLanguage',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the language you\'re most comfortable with.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = lang.name == _selected;
                      return _LanguageCard(
                        language: lang,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selected = lang.name),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AppButton(
                    label: 'Continue',
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('has_selected_language', true);
                      if (context.mounted) {
                        context.go(RouteNames.authSuccess);
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
              ? AppColors.primaryGreen
              : (isDark ? AppColors.cardDark : AppColors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.lineDark : AppColors.lineLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? AppColors.greenShadow(
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  opacity: 0.2,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              language.script,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.white
                    : (isDark ? AppColors.white : AppColors.inkDark),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              language.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isSelected
                    ? AppColors.white.withValues(alpha: 0.9)
                    : (isDark ? AppColors.white.withValues(alpha: 0.7) : AppColors.inkSoft),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
