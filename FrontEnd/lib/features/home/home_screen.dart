import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/modern_components.dart';
import '../../core/widgets/modern_animations.dart';
import '../../core/widgets/floating_components.dart';
import '../../core/premium_components.dart';
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
    await ref.read(homeProvider.notifier).loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: CustomScrollView(
          slivers: [
          // Floating App Bar
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
                      'S',
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
          
          // Floating Search Bar
          SliverToBoxAdapter(
            child: FloatingSearchBar(
              hintText: 'Search recipes, ingredients...',
              onTap: () => context.push('/search'),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: homeState.isLoading
                ? _buildLoadingState()
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        bottom: 100, // Space for floating nav
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting
                            AnimatedListItem(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(homeState.userName),
                                    style: AppTypography.displaySmall.copyWith(
                                      color: isDark
                                          ? AppColors.darkOnSurface
                                          : AppColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Ready to stay on track and save today?',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.darkOnSurfaceVariant
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: AppSpacing.lg),
                            
                            // Stats Row
                            AnimatedListItem(
                              delay: 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.local_fire_department,
                                      label: 'Day streak',
                                      value: '7',
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.restaurant,
                                      label: 'Meals',
                                      value: '21',
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.recycling,
                                      label: 'Waste saved',
                                      value: '3',
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Savings Card
                            AnimatedListItem(
                              delay: 2,
                              child: ModernCard(
                                title: 'Savings Summary',
                                subtitle: 'Saved this month',
                                leading: Container(
                                  padding: const EdgeInsets.all(AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: (isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.savings,
                                    color: isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$142.50',
                                      style: AppTypography.displayMedium.copyWith(
                                        color: isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          color: isDark
                                              ? AppColors.primaryLight
                                              : AppColors.primary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '12% more than last month',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: isDark
                                                ? AppColors.primaryLight
                                                : AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Budget Card
                            AnimatedListItem(
                              delay: 3,
                              child: ProgressCard(
                                icon: Icons.account_balance_wallet,
                                label: 'Budget Status',
                                value: '64% Spent',
                                progress: 0.64,
                                maxValue: 400,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                              ),
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Today's Plan
                            AnimatedListItem(
                              delay: 4,
                              child: ModernCard(
                                title: 'Your Plan for Today',
                                trailing: TextButton(
                                  onPressed: () => context.push('/plan'),
                                  child: Text(
                                    'View Full Plan',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: homeState.recommendations.isEmpty
                                      ? todayMeals
                                          .take(3)
                                          .map(
                                            (meal) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: AppSpacing.xs,
                                              ),
                                              child: _buildMealItem(
                                                context: context,
                                                isDark: isDark,
                                                meal: meal,
                                              ),
                                            ),
                                          )
                                          .toList()
                                      : homeState.recommendations
                                          .take(3)
                                          .map(
                                            (r) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: AppSpacing.xs,
                                              ),
                                              child: _buildRecoItem(
                                                context: context,
                                                isDark: isDark,
                                                reco: r,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Pantry Alert
                            AnimatedListItem(
                              delay: 5,
                              child: AlertCard(
                                type: AlertType.warning,
                                title: 'Pantry Alerts',
                                message:
                                    'Spinach and Greek yogurt should be used this week.',
                                actions: [
                                  TextButton(
                                    onPressed: () => context.push('/pantry'),
                                    child: Text(
                                      'View Pantry',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: isDark
                                            ? AppColors.warning
                                            : AppColors.warning,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Quick Meal Button
                            AnimatedListItem(
                              delay: 6,
                              child: AnimatedButton(
                                onPressed: () => context.push('/quick-meal'),
                                backgroundColor: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bolt, size: 18),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Quick Meal Mode',
                                      style: AppTypography.labelLarge.copyWith(
                                        color: isDark
                                            ? AppColors.darkBackground
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          ],
        ),
      ),
      extendBody: true,
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
    if (name == null) return 'Good morning!';
    final first = name.split(' ').first;
    return 'Good morning, $first!';
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
                    '$time min${costStr.isNotEmpty ? ' • $costStr' : ''}${cuisine.isNotEmpty ? ' • $cuisine' : ''}',
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
                color: meal.tint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                meal.icon,
                color: meal.tint,
                size: 20,
              ),
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
                    '${meal.minutes} min • ${meal.kcal} kcal',
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
