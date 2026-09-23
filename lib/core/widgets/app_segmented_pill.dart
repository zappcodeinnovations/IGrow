import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Item definition for [AppSegmentedPillGroup].
class AppPillOption<T> {
  const AppPillOption({
    required this.value,
    required this.label,
    this.icon,
    this.emoji,
    this.badge,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? emoji;
  final String? badge;
}

/// A modern, soft segmented pill selector designed to replace clunky dropdowns.
/// Gives immediate visual feedback, rounded organic aesthetic, and haptic response.
class AppSegmentedPillGroup<T> extends StatelessWidget {
  const AppSegmentedPillGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.isExpanded = false,
  });

  final List<AppPillOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chips = options.map((option) {
      final isSelected = option.value == selectedValue;

      Widget pill = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : (isDark ? AppColors.cardDark : const Color(0xFFF2F6F0)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.lineDark : const Color(0xFFE2E9DF)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (option.emoji != null) ...[
              Text(option.emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ] else if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.inkSoft),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              option.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.inkDark),
              ),
            ),
            if (option.badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  option.badge!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.accentOrange,
                  ),
                ),
              ),
            ],
          ],
        ),
      );

      return InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onChanged(option.value);
        },
        borderRadius: BorderRadius.circular(20),
        child: pill,
      );
    }).toList();

    if (isExpanded) {
      return Row(
        children: chips
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: c,
                  ),
                ))
            .toList(),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}
