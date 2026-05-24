import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/widgets/floating_components.dart';
import '../../core/widgets/modern_animations.dart';
import '../../core/widgets/modern_components.dart';
import '../../features/budget/budget_provider.dart';
import '../../features/grocery/grocery_provider.dart';
import '../../features/meal_plan/meal_plan_provider.dart';
import '../../features/pantry/pantry_provider.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/recipe_image.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeProvider.notifier).loadRecommendations();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(homeProvider.notifier).loadRecommendations(),
      ref.read(budgetProvider.notifier).refresh(),
      ref.read(groceryProvider.notifier).refresh(),
      ref.read(pantryProvider.notifier).refresh(),
      ref.read(mealPlanProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final budgetState = ref.watch(budgetProvider);
    final groceryState = ref.watch(groceryProvider);
    final pantryState = ref.watch(pantryProvider);
    final mealPlanState = ref.watch(mealPlanProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading =
        homeState.isLoading &&
        budgetState.isLoading &&
        pantryState.isLoading &&
        groceryState.isLoading &&
        mealPlanState.isLoading;

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
                          _avatarInitial(homeState.userName),
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
                          budgetState: budgetState,
                          groceryState: groceryState,
                          pantryState: pantryState,
                          mealPlanState: mealPlanState,
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
    required BudgetState budgetState,
    required GroceryListState groceryState,
    required PantryListState pantryState,
    required MealPlanState mealPlanState,
  }) {
    final urgentPantry =
        pantryState.items.where((item) => item.isExpiringSoon).toList()..sort(
          (a, b) => (a.daysToExpiry ?? 999).compareTo(b.daysToExpiry ?? 999),
        );
    final groceryTotal = groceryState.items.length;
    final groceryDone = groceryState.checkedCount;
    final groceryProgress = groceryTotal == 0
        ? 0.0
        : groceryDone / groceryTotal;
    final meals = mealPlanState.meals.isNotEmpty
        ? mealPlanState.meals
        : todayMeals;
    final recommendations = homeState.recommendations;
    final quickMeals = homeState.quickMeals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedListItem(
          child: _buildWelcomePanel(
            context: context,
            isDark: isDark,
            name: homeState.userName,
            budgetState: budgetState,
            urgentCount: urgentPantry.length,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 1,
          child: _buildNextBestAction(
            context: context,
            isDark: isDark,
            groceryTotal: groceryTotal,
            urgentCount: urgentPantry.length,
            mealCount: mealPlanState.meals.length,
            hasRecommendations: recommendations.isNotEmpty,
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
                  value: meals.length.toString(),
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  icon: Icons.kitchen_outlined,
                  label: 'Use soon',
                  value: urgentPantry.length.toString(),
                  color: urgentPantry.isEmpty
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
            meals: meals,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 4,
          child: _buildOperationsGrid(
            context: context,
            isDark: isDark,
            budgetState: budgetState,
            groceryProgress: groceryProgress,
            groceryTotal: groceryTotal,
            urgentPantry: urgentPantry,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedListItem(
          delay: 5,
          child: _buildQuickMealCard(
            context: context,
            isDark: isDark,
            quickMeals: quickMeals,
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
    required BudgetState budgetState,
    required int urgentCount,
  }) {
    final remaining = budgetState.remaining;
    final budgetLine = budgetState.weeklyBudget > 0
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
            'Here is the calmest path through meals, groceries, and pantry today.',
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
    required int groceryTotal,
    required int urgentCount,
    required int mealCount,
    required bool hasRecommendations,
  }) {
    final action = _homeAction(
      groceryTotal: groceryTotal,
      urgentCount: urgentCount,
      mealCount: mealCount,
      hasRecommendations: hasRecommendations,
    );

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
    required List<Map<String, dynamic>> recommendations,
    required List<Meal> meals,
  }) {
    final hasRecommendations = recommendations.isNotEmpty;

    return ModernCard(
      title: hasRecommendations ? 'Recommended for you' : 'Today at a glance',
      subtitle: hasRecommendations
          ? 'From the recommendation engine'
          : 'A simple fallback plan while data loads',
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
            : meals
                  .take(3)
                  .map(
                    (meal) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: _buildMealItem(
                        context: context,
                        isDark: isDark,
                        meal: meal,
                      ),
                    ),
                  )
                  .toList(),
      ),
    );
  }

  Widget _buildOperationsGrid({
    required BuildContext context,
    required bool isDark,
    required BudgetState budgetState,
    required double groceryProgress,
    required int groceryTotal,
    required List<dynamic> urgentPantry,
  }) {
    return Column(
      children: [
        ProgressCard(
          icon: Icons.account_balance_wallet,
          label: 'Weekly Budget',
          value:
              '${(budgetState.percentUsed * 100).round()}% spent - \$${budgetState.remaining.toStringAsFixed(0)} left',
          progress: budgetState.percentUsed,
          maxValue: budgetState.weeklyBudget,
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
                subtitle: urgentPantry.isEmpty
                    ? 'Inventory is steady'
                    : '${urgentPantry.length} use soon',
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
    required List<Map<String, dynamic>> quickMeals,
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

  _HomeAction _homeAction({
    required int groceryTotal,
    required int urgentCount,
    required int mealCount,
    required bool hasRecommendations,
  }) {
    if (urgentCount > 0) {
      return const _HomeAction(
        icon: Icons.kitchen_outlined,
        title: 'Use pantry first',
        subtitle: 'Start with ingredients that may expire soon.',
        route: '/pantry',
        color: AppColors.warning,
      );
    }
    if (mealCount == 0 && hasRecommendations) {
      return _HomeAction(
        icon: Icons.auto_awesome,
        title: 'Turn recommendations into a plan',
        subtitle: 'Your backend suggestions are ready to review.',
        route: '/plan',
        color: AppColors.primary,
      );
    }
    if (groceryTotal > 0) {
      return const _HomeAction(
        icon: Icons.shopping_cart_outlined,
        title: 'Finish the grocery list',
        subtitle: 'Check off items as you shop.',
        route: '/grocery',
        color: AppColors.secondary,
      );
    }
    return _HomeAction(
      icon: Icons.bolt,
      title: 'Find a quick meal',
      subtitle: 'Get something practical for today.',
      route: '/quick-meal',
      color: AppColors.primary,
    );
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
    required Map<String, dynamic> reco,
  }) {
    final name = reco['name'] as String? ?? 'Recipe';
    final time = reco['totalTimeMinutes'] as int? ?? 30;
    final cost = reco['estimatedCost'];
    final costStr = cost != null ? '\$${(cost as num).toStringAsFixed(0)}' : '';
    final cuisine = reco['cuisineType'] as String? ?? '';

    return GestureDetector(
      onTap: () => context.push('/recipe/${reco['id']}'),
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
              imageUrl: reco['imageUrl'] as String?,
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

  Widget _buildMealItem({
    required BuildContext context,
    required bool isDark,
    required dynamic meal,
  }) {
    return GestureDetector(
      onTap: () => context.push('/recipe/0'),
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: meal.tint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(meal.icon, color: meal.tint, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${meal.minutes} min | ${meal.kcal} kcal',
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
