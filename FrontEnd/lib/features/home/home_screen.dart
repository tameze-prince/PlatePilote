import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/repositories/dashboard_repository.dart';
import '../../core/widgets/floating_components.dart';
import '../../core/widgets/modern_animations.dart';
import '../../core/widgets/modern_components.dart';
import '../../shared/widgets/recipe_image.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _onRefresh() async {
    await ref.read(homeProvider.notifier).loadHome();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = homeState.isLoading;

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: FloatingAppBar(
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isDark
                            ? AppColors.darkPrimaryContainer
                            : AppColors.primaryContainer,
                        child: Text(
                          _avatarInitial(homeState.dashboard?.firstName),
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'PlatePilot',
                        style: AppTypography.titleLarge.copyWith(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => context.push('/notifications'),
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: FloatingSearchBar(
                  hintText: 'Search recipes, ingredients...',
                  onTap: () => context.push('/search'),
                ),
              ),
              SliverToBoxAdapter(
                child: isLoading
                    ? _buildLoadingState()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          100,
                        ),
                        child: _buildDashboard(
                          context: context,
                          isDark: isDark,
                          homeState: homeState,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }

  Widget _buildDashboard({
    required BuildContext context,
    required bool isDark,
    required HomeState homeState,
  }) {
    final dashboard = homeState.dashboard;
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
          child: _buildWelcomePanel(
            context: context,
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
          child: _buildNextBestAction(
            context: context,
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
          child: _buildPrimaryPlanCard(
            context: context,
            isDark: isDark,
            recommendations: recommendations,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 4,
          child: _buildOperationsGrid(
            context: context,
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
          child: _buildQuickMealCard(
            context: context,
            isDark: isDark,
            quickMeals: recommendations,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(delay: 6, child: _buildQuickActions(context, isDark)),
      ],
    );
  }

  Widget _buildWelcomePanel({
    required BuildContext context,
    required bool isDark,
    required String? name,
    required double? budgetRemaining,
    required double? budgetWeekly,
    required int urgentCount,
  }) {
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
              _StatusPill(
                icon: Icons.account_balance_wallet_outlined,
                label: budgetLine,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              _StatusPill(
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

  Widget _buildNextBestAction({
    required BuildContext context,
    required bool isDark,
    required String? nextAction,
  }) {
    final action = _homeAction(nextAction);

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
            onPressed: () => context.push(action.route),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryPlanCard({
    required BuildContext context,
    required bool isDark,
    required List<RecommendationItem> recommendations,
  }) {
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
                      child: _buildRecoItem(
                        context: context,
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

  Widget _buildOperationsGrid({
    required BuildContext context,
    required bool isDark,
    required double? budgetRemaining,
    required double? budgetPercent,
    required double? budgetWeekly,
    required double groceryProgress,
    required int groceryTotal,
    required int urgentCount,
  }) {
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
              child: _ActionTile(
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
              child: _ActionTile(
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

  Widget _buildQuickMealCard({
    required BuildContext context,
    required bool isDark,
    required List<RecommendationItem> quickMeals,
  }) {
    if (quickMeals.isEmpty) {
      return AlertCard(
        type: AlertType.info,
        title: 'Need dinner fast?',
        message:
            'Quick Meal Mode can suggest meals that fit your pantry and time.',
        actions: [
          TextButton(
            onPressed: () => context.push('/quick-meal'),
            child: Text(
              'Open Quick Meal',
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
                child: _buildRecoItem(
                  context: context,
                  isDark: isDark,
                  reco: reco,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: AnimatedButton(
            onPressed: () => context.push('/plan'),
            backgroundColor: isDark
                ? AppColors.primaryLight
                : AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Plan Week',
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark ? AppColors.darkBackground : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AnimatedButton(
            onPressed: () => context.push('/grocery/add'),
            backgroundColor: AppColors.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_shopping_cart, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Add Items',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _HomeAction _homeAction(String? nextAction) {
    switch (nextAction) {
      case 'generate_plan':
        return _HomeAction(
          icon: Icons.auto_awesome,
          title: 'Plan Your First Week',
          subtitle: 'Get meals and groceries moving in under a minute.',
          route: '/plan',
          color: AppColors.primary,
        );
      case 'activate_plan':
        return _HomeAction(
          icon: Icons.play_circle_outline,
          title: 'Activate Your Meal Plan',
          subtitle: 'Your plan is ready — activate it to begin.',
          route: '/plan',
          color: AppColors.primary,
        );
      case 'generate_grocery':
        return _HomeAction(
          icon: Icons.shopping_cart_outlined,
          title: 'Generate Grocery List',
          subtitle: 'Subtract pantry items and keep the budget visible.',
          route: '/grocery',
          color: AppColors.secondary,
        );
      case 'shop_grocery':
        return _HomeAction(
          icon: Icons.shopping_cart_outlined,
          title: 'Continue Shopping',
          subtitle: 'Finish checkout and update pantry automatically.',
          route: '/grocery',
          color: AppColors.secondary,
        );
      case 'use_pantry':
        return _HomeAction(
          icon: Icons.kitchen_outlined,
          title: 'Use Expiring Items',
          subtitle: 'Reduce waste before planning more meals.',
          route: '/pantry',
          color: AppColors.warning,
        );
      case 'explore_recipes':
        return _HomeAction(
          icon: Icons.explore_outlined,
          title: 'Explore Recipes',
          subtitle: 'Discover something new to cook.',
          route: '/search',
          color: AppColors.primary,
        );
      default:
        return _HomeAction(
          icon: Icons.bolt,
          title: 'Find a quick meal',
          subtitle: 'Get something practical for today.',
          route: '/quick-meal',
          color: AppColors.primary,
        );
    }
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingSkeleton(height: 32, width: 240),
          const SizedBox(height: AppSpacing.xs),
          const LoadingSkeleton(height: 16, width: 200),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceContainerHigh
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceContainerHigh
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceContainerHigh
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainerHigh
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainerHigh
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),
        ],
      ),
    );
  }

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

  String _avatarInitial(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'P';
    return trimmed.characters.first.toUpperCase();
  }

  Widget _buildRecoItem({
    required BuildContext context,
    required bool isDark,
    required RecommendationItem reco,
  }) {
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
            RecipeImage(
              imageUrl: reco.imageUrl,
              cuisine: cuisine,
            ),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.primaryLight : AppColors.primary;

    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAction {
  const _HomeAction({
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
