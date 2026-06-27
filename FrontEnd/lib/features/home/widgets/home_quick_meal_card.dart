import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/pp_empty_state.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/repositories/dashboard_repository.dart';
import '../../../core/widgets/modern_components.dart';
import 'home_recommendation_item.dart';

/// Construit la carte des repas rapides.
class HomeQuickMealCard extends StatelessWidget {
  const HomeQuickMealCard({
    super.key,
    required this.isDark,
    required this.quickMeals,
  });

  final bool isDark;
  final List<RecommendationItem> quickMeals;

  @override
  Widget build(BuildContext context) {
    if (quickMeals.isEmpty) {
      final l10n = context.l10n!;
      return PpEmptyState(
        icon: Icons.restaurant_menu,
        title: l10n.emptyQuickMealTitle,
        subtitle: l10n.emptyQuickMealSubtitle,
        actionLabel: l10n.emptyQuickMealCta,
        onAction: () => context.push('/pantry'),
      );
    }

    return ModernCard(
      title: 'Fast options',
      subtitle: 'Ready in 30 minutes or less',
      trailing: TextButton(
        onPressed: () => context.push('/quick-meal'),
        child: Text(
          'More',
          style: AppTypography.labelMedium.copyWith(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        children: quickMeals
            .take(2)
            .map(
              (reco) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: HomeRecommendationItem(isDark: isDark, reco: reco),
              ),
            )
            .toList(),
      ),
    );
  }
}
