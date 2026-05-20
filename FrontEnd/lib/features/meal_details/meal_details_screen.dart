import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/plate_scaffold.dart';

class MealDetailsScreen extends StatelessWidget {
  const MealDetailsScreen({required this.mealId, super.key});

  final String mealId;

  @override
  Widget build(BuildContext context) {
    final index = int.tryParse(mealId) ?? 0;
    final meal = demoMeals[index.clamp(0, demoMeals.length - 1)];

    return PlateScaffold(
      title: 'Meal Details',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            color: meal.tint.withValues(alpha: context.isDark ? 0.18 : 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(meal.icon, color: meal.tint, size: 56),
                const SizedBox(height: AppSpacing.md),
                Text(meal.title, style: context.text.headlineLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${meal.day} - ${meal.type} - ${meal.minutes} min - ${meal.kcal} kcal',
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recommendation fit', style: context.text.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                const _FitRow(label: 'Budget efficiency', value: 'Strong'),
                const _FitRow(
                  label: 'Pantry utilization',
                  value: '3 ingredients',
                ),
                const _FitRow(label: 'Skill match', value: 'Balanced'),
                const _FitRow(label: 'Diet compatibility', value: 'Approved'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Open Recipe',
            icon: Icons.menu_book,
            onPressed: () => context.push('/recipe/$index'),
          ),
        ],
      ),
    );
  }
}

class _FitRow extends StatelessWidget {
  const _FitRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: ColorTokens.primaryGreen,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(label, style: context.text.bodyLarge)),
          Text(value, style: context.text.labelSmall),
        ],
      ),
    );
  }
}
