import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/modern_animations.dart';
import '../../../core/widgets/modern_components.dart';
import '../home_provider.dart';
import 'home_next_best_action.dart';
import 'home_operations_grid.dart';
import 'home_primary_plan_card.dart';
import 'home_quick_actions.dart';
import 'home_quick_meal_card.dart';
import 'home_welcome_panel.dart';

/// Widget qui compose tous les panels du tableau de bord d'accueil.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.state,
    required this.isDark,
  });

  final HomeState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dashboard = state.dashboard;
    final recommendations = dashboard?.recommendations ?? [];
    final groceryList = dashboard?.groceryList;
    final pantry = dashboard?.pantry;
    final budget = dashboard?.budget;
    final activePlan = dashboard?.activePlan;

    final urgentCount = pantry?.alertCount ?? 0;
    final groceryProgress = groceryList?.progress ?? 0.0;
    final groceryTotal = groceryList?.totalItems ?? 0;
    final groceryDone = groceryList?.checkedItems ?? 0;
    final mealCount = activePlan?.entryCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedListItem(
          child: HomeWelcomePanel(
            isDark: isDark,
            name: dashboard?.firstName,
            budgetRemaining: budget?.remaining,
            budgetWeekly: budget?.amount,
            urgentCount: urgentCount,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 1,
          child: HomeNextBestAction(
            isDark: isDark,
            nextAction: dashboard?.nextAction,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 2,
          child: Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.restaurant_menu,
                  label: 'Meals ready',
                  value: mealCount.toString(),
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  icon: Icons.kitchen_outlined,
                  label: 'Use soon',
                  value: urgentCount.toString(),
                  color: urgentCount == 0
                      ? AppColors.tertiary
                      : AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Grocery',
                  value: '$groceryDone/$groceryTotal',
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 3,
          child: HomePrimaryPlanCard(
            isDark: isDark,
            recommendations: recommendations,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 4,
          child: HomeOperationsGrid(
            isDark: isDark,
            budgetRemaining: budget?.remaining,
            budgetPercent: budget?.percentUsed,
            budgetWeekly: budget?.amount,
            groceryProgress: groceryProgress,
            groceryTotal: groceryTotal,
            urgentCount: urgentCount,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 5,
          child: HomeQuickMealCard(
            isDark: isDark,
            quickMeals: recommendations,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 6,
          child: HomeQuickActions(isDark: isDark),
        ),
      ],
    );
  }
}
