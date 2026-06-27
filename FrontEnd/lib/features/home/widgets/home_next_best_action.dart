import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/premium_components.dart';

/// Modèle interne représentant une action recommandée sur l'accueil.
class HomeAction {
  const HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
}

/// Construit la carte de la prochaine action recommandée.
class HomeNextBestAction extends StatelessWidget {
  const HomeNextBestAction({
    super.key,
    required this.isDark,
    required this.nextAction,
  });

  final bool isDark;
  final String? nextAction;

  /// Retourne l'action recommandée en fonction de l'état courant.
  HomeAction _resolveAction(String? nextAction) {
    switch (nextAction) {
      case 'generate_plan':
        return HomeAction(
          icon: Icons.auto_awesome,
          title: 'Plan Your First Week',
          subtitle: 'Get meals and groceries moving in under a minute.',
          route: '/plan',
          color: AppColors.primary,
        );
      case 'activate_plan':
        return HomeAction(
          icon: Icons.play_circle_outline,
          title: 'Activate Your Meal Plan',
          subtitle: 'Your plan is ready — activate it to begin.',
          route: '/plan',
          color: AppColors.primary,
        );
      case 'generate_grocery':
        return HomeAction(
          icon: Icons.shopping_cart_outlined,
          title: 'Generate Grocery List',
          subtitle: 'Subtract pantry items and keep the budget visible.',
          route: '/grocery',
          color: AppColors.secondary,
        );
      case 'shop_grocery':
        return HomeAction(
          icon: Icons.shopping_cart_outlined,
          title: 'Continue Shopping',
          subtitle: 'Finish checkout and update pantry automatically.',
          route: '/grocery',
          color: AppColors.secondary,
        );
      case 'use_pantry':
        return HomeAction(
          icon: Icons.kitchen_outlined,
          title: 'Use Expiring Items',
          subtitle: 'Reduce waste before planning more meals.',
          route: '/pantry',
          color: AppColors.warning,
        );
      case 'explore_recipes':
        return HomeAction(
          icon: Icons.explore_outlined,
          title: 'Explore Recipes',
          subtitle: 'Discover something new to cook.',
          route: '/search',
          color: AppColors.primary,
        );
      default:
        return HomeAction(
          icon: Icons.bolt,
          title: 'Find a quick meal',
          subtitle: 'Get something practical for today.',
          route: '/quick-meal',
          color: AppColors.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = _resolveAction(nextAction);

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(action.icon, color: action.color, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  action.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton.filled(
            tooltip: 'Open',
            onPressed: () => context.push(action.route),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
