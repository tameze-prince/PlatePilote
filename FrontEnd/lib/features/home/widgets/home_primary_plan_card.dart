import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/repositories/dashboard_repository.dart';
import '../../../core/widgets/modern_components.dart';
import 'home_recommendation_item.dart';

/// Construit la carte des recommandations de repas.
class HomePrimaryPlanCard extends StatelessWidget {
  const HomePrimaryPlanCard({
    super.key,
    required this.isDark,
    required this.recommendations,
  });

  final bool isDark;
  final List<RecommendationItem> recommendations;

  @override
  Widget build(BuildContext context) {
    final hasRecommendations = recommendations.isNotEmpty;

    return ModernCard(
      title: hasRecommendations ? 'Recommended for you' : 'Today at a glance',
      subtitle: hasRecommendations
          ? 'From the recommendation engine'
          : 'No recommendations yet',
      trailing: TextButton(
        onPressed: () => context.push('/plan'),
        child: Text(
          'Plan',
          style: AppTypography.labelMedium.copyWith(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        children: hasRecommendations
            ? recommendations
                  .take(3)
                  .map(
                    (reco) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: HomeRecommendationItem(
                        isDark: isDark,
                        reco: reco,
                      ),
                    ),
                  )
                  .toList()
            : [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'Generate a meal plan to see recommendations here.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
