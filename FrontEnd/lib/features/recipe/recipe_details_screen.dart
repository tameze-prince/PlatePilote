import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/recipe_image.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    final index = int.tryParse(recipeId) ?? 0;
    final meal = demoMeals[index.clamp(0, demoMeals.length - 1)];

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, 0,
                    ),
                    child: RecipeHeroImage(
                      imageUrl: meal.imageUrl,
                      cuisine: meal.title,
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        borderRadius: AppRadius.full,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl,
                  ),
                  children: [
                    Text(
                      meal.title,
                      style: AppTypography.headlineLarge.copyWith(
                        color: PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.timer_outlined,
                          label: '${meal.minutes} min',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _InfoChip(
                          icon: Icons.local_fire_department,
                          label: '${meal.kcal} kcal',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _InfoChip(
                          icon: Icons.attach_money,
                          label: 'Budget friendly',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Ingredients',
                      style: AppTypography.titleLarge.copyWith(
                        color: PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: PremiumTheme.glass(context, elevated: true),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primaryAccentGreen,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: PremiumTheme.textPrimary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Steps',
                      style: AppTypography.titleLarge.copyWith(
                        color: PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final step in const [
                      'Prep ingredients and warm the pan.',
                      'Cook the protein or grain base until tender.',
                      'Fold in vegetables and sauce, then season to taste.',
                    ].indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: PremiumTheme.glass(context, elevated: true),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primaryAccentGreen,
                                child: Text(
                                  '${step.$1 + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  step.$2,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: PremiumTheme.textPrimary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.swap_horiz, size: 18),
                            label: const Text('Replace'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.restaurant, size: 18),
                            label: const Text('Cook'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: PremiumTheme.glass(context, elevated: true),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryAccentGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: PremiumTheme.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
