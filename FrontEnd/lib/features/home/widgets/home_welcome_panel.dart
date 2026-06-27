import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/premium_components.dart';
import 'home_status_pill.dart';

/// Construit le panneau de bienvenue avec le budget et les alertes.
class HomeWelcomePanel extends StatelessWidget {
  const HomeWelcomePanel({
    super.key,
    required this.isDark,
    required this.name,
    required this.budgetRemaining,
    required this.budgetWeekly,
    required this.urgentCount,
  });

  final bool isDark;
  final String? name;
  final double? budgetRemaining;
  final double? budgetWeekly;
  final int urgentCount;

  /// Génère un message de bienvenue avec le prénom.
  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    if (name == null || name.trim().isEmpty) return '$greeting!';
    final first = name.split(' ').first;
    return '$greeting, $first!';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = budgetRemaining ?? 0;
    final budgetLine = (budgetWeekly ?? 0) > 0
        ? '\$${remaining.clamp(0, double.infinity).toStringAsFixed(0)} left this week'
        : 'Set a weekly budget when you are ready';

    return PremiumCard(
      variant: PremiumCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(name),
            style: AppTypography.displaySmall.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Plan the week, turn it into groceries, and use what you already have.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              HomeStatusPill(
                icon: Icons.account_balance_wallet_outlined,
                label: budgetLine,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              HomeStatusPill(
                icon: urgentCount == 0
                    ? Icons.check_circle_outline
                    : Icons.schedule_outlined,
                label: urgentCount == 0
                    ? 'Pantry looks steady'
                    : '$urgentCount item${urgentCount == 1 ? '' : 's'} to use soon',
                color: urgentCount == 0
                    ? AppColors.tertiary
                    : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
