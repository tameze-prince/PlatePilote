import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../shared/models/ingredient.dart';
import '../premium_components.dart';

class SearchResultItem extends StatelessWidget {
  const SearchResultItem({
    required this.ingredient,
    required this.query,
    required this.icon,
    this.selected = false,
    this.trailingIcon,
    this.onTap,
    super.key,
  });

  final Ingredient ingredient;
  final String query;
  final IconData icon;
  final bool selected;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final price = ingredient.averagePricePerKg;
    final calories = ingredient.caloriesPer100g;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryAccentGreen
                    : AppColors.primaryAccentGreen.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                selected ? Icons.check : icon,
                size: 20,
                color: selected ? Colors.white : AppColors.primaryAccentGreen,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedName(
                    name: ingredient.canonicalName,
                    query: query,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _MetaChip(label: ingredient.category),
                      if (price != null)
                        _MetaChip(label: '\$${price.toStringAsFixed(2)}/kg'),
                      if (calories != null)
                        _MetaChip(label: '${calories.toStringAsFixed(0)} kcal'),
                      if (ingredient.popularityScore > 0)
                        _MetaChip(label: '${ingredient.popularityScore} pop'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              trailingIcon ??
                  (selected ? Icons.check_circle : Icons.add_circle_outline),
              size: 22,
              color: selected
                  ? AppColors.primaryAccentGreen
                  : PremiumTheme.textTertiary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightedName extends StatelessWidget {
  const _HighlightedName({required this.name, required this.query});

  final String name;
  final String query;

  @override
  Widget build(BuildContext context) {
    final normalizedName = name.toLowerCase();
    final normalizedQuery = query.trim().toLowerCase();
    final matchStart = normalizedQuery.isEmpty
        ? -1
        : normalizedName.indexOf(normalizedQuery);

    if (matchStart < 0) {
      return Text(
        name,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: PremiumTheme.textPrimary(context),
        ),
      );
    }

    final matchEnd = matchStart + normalizedQuery.length;
    return RichText(
      text: TextSpan(
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: PremiumTheme.textPrimary(context),
        ),
        children: [
          TextSpan(text: name.substring(0, matchStart)),
          TextSpan(
            text: name.substring(matchStart, matchEnd),
            style: const TextStyle(color: AppColors.primaryAccentGreen),
          ),
          TextSpan(text: name.substring(matchEnd)),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Text(
      label,
      style: AppTypography.labelSmall.copyWith(
        color: PremiumTheme.textSecondary(context),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
