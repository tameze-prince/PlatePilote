import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/modern_components.dart';
import 'home_action_tile.dart';

/// Construit la grille des opérations (budget, courses, garde-manger).
class HomeOperationsGrid extends StatelessWidget {
  const HomeOperationsGrid({
    super.key,
    required this.isDark,
    required this.budgetRemaining,
    required this.budgetPercent,
    required this.budgetWeekly,
    required this.groceryProgress,
    required this.groceryTotal,
    required this.urgentCount,
  });

  final bool isDark;
  final double? budgetRemaining;
  final double? budgetPercent;
  final double? budgetWeekly;
  final double groceryProgress;
  final int groceryTotal;
  final int urgentCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProgressCard(
          icon: Icons.account_balance_wallet,
          label: 'Weekly Budget',
          value: (budgetWeekly ?? 0) > 0
              ? '${((budgetPercent ?? 0) * 100).round()}% spent - \$${(budgetRemaining ?? 0).toStringAsFixed(0)} left'
              : 'Set a weekly budget when ready',
          progress: budgetPercent ?? 0,
          maxValue: budgetWeekly ?? 0,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: HomeActionTile(
                icon: Icons.shopping_cart_outlined,
                title: 'Grocery',
                subtitle: groceryTotal == 0
                    ? 'Build your list'
                    : '${(groceryProgress * 100).round()}% complete',
                onTap: () => context.push('/grocery'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: HomeActionTile(
                icon: Icons.kitchen_outlined,
                title: 'Pantry',
                subtitle: urgentCount == 0
                    ? 'Inventory is steady'
                    : '$urgentCount use soon',
                onTap: () => context.push('/pantry'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
