import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/plate_scaffold.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    final index = int.tryParse(recipeId) ?? 0;
    final meal = demoMeals[index.clamp(0, demoMeals.length - 1)];

    return PlateScaffold(
      title: 'Recipe',
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
                const SizedBox(height: AppSpacing.lg),
                Text(meal.title, style: context.text.headlineLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${meal.minutes} mins - ${meal.kcal} kcal - Budget friendly',
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Ingredients', style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          for (final ingredient in const [
            'Fresh spinach',
            'Greek yogurt',
            'Quinoa',
            'Cherry tomatoes',
            'Lemon herb seasoning',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: ColorTokens.primaryGreen,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(ingredient, style: context.text.bodyLarge),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text('Steps', style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          for (final step in const [
            'Prep ingredients and warm the pan.',
            'Cook the protein or grain base until tender.',
            'Fold in vegetables and sauce, then season to taste.',
          ].indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: ColorTokens.primaryGreen,
                      child: Text(
                        '${step.$1 + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(step.$2, style: context.text.bodyLarge),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Replace',
                  icon: Icons.swap_horiz,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recipe replaced')),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: PrimaryButton(
                  label: 'Start Cooking',
                  icon: Icons.restaurant,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Starting cooking timer...'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
