import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/plate_scaffold.dart';

class QuickMealScreen extends StatelessWidget {
  const QuickMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return PlateScaffold(
      title: 'Quick Meal',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            color: ColorTokens.primaryGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bolt, color: Colors.white, size: 34),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Dinner in 18 minutes',
                  style: context.text.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Based on your pantry, budget, and low-prep preference.',
                  style: context.text.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Best Matches', style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          ...demoMeals
              .take(isTablet ? demoMeals.length : 3)
              .map(
                (meal) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(meal.icon, color: meal.tint, size: 32),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                meal.title,
                                style: context.text.headlineSmall,
                              ),
                            ),
                            Text(
                              '${meal.minutes}m',
                              style: context.text.labelSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Uses spinach, yogurt, quinoa, and pantry staples already available.',
                          style: context.text.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: 'Swap',
                                icon: Icons.swap_horiz,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Swapping meal suggestion...',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: PrimaryButton(
                                label: 'Cook',
                                icon: Icons.restaurant,
                                onPressed: () => context.push('/recipe/0'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
