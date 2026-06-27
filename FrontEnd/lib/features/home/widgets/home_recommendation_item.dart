import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/repositories/dashboard_repository.dart';
import '../../../shared/widgets/recipe_image.dart';

/// Construit un élément de recommandation individuel.
class HomeRecommendationItem extends StatelessWidget {
  const HomeRecommendationItem({
    super.key,
    required this.isDark,
    required this.reco,
  });

  final bool isDark;
  final RecommendationItem reco;

  @override
  Widget build(BuildContext context) {
    final name = reco.name ?? 'Recipe';
    final time = reco.totalTimeMinutes ?? 30;
    final cost = reco.estimatedCost;
    final costStr = cost != null ? '\$${cost.toStringAsFixed(0)}' : '';
    final cuisine = reco.cuisineType ?? '';

    return GestureDetector(
      onTap: () => context.push('/recipe/${reco.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceContainerLow
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            RecipeImage(imageUrl: reco.imageUrl, cuisine: cuisine),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$time min${costStr.isNotEmpty ? ' | $costStr' : ''}${cuisine.isNotEmpty ? ' | $cuisine' : ''}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
