import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/widgets/meal_card.dart';
import '../../shared/models/demo_data.dart';
import 'meal_plan_provider.dart';

class WeeklyPlanScreen extends ConsumerWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealPlanProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        child: RefreshIndicator(
          onRefresh: () => ref.read(mealPlanProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              FloatingHeader(
                title: 'Your Week',
                subtitle: state.currentPlan != null
                    ? '${state.currentPlan!.startDate} – ${state.currentPlan!.endDate}'
                    : state.useDemoFallback
                        ? 'Sample plan — tap to generate'
                        : 'Plan your meals',
                actions: [
                  IconButton(
                    onPressed: () => context.push('/plan-history'),
                    icon: const Icon(Icons.history),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionRow(context, ref, state, isTablet, screenWidth),
              const SizedBox(height: AppSpacing.md),
              if (state.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.error != null)
                _buildErrorCard(context, ref)
              else if (state.isGenerating)
                _buildGeneratingState(context)
              else ...[
                ...state.meals.indexed.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: MealCard(
                      meal: entry.$2,
                      onTap: () => _onMealTap(context, ref, entry.$1, entry.$2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildBudgetCard(context, ref, state),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    WidgetRef ref,
    MealPlanState state,
    bool isTablet,
    double screenWidth,
  ) {
    final actions = [
      _ActionTile(
        icon: Icons.auto_awesome,
        label: 'Plan This Week',
        color: AppColors.primaryAccentGreen,
        onTap: state.isGenerating
            ? null
            : () => ref.read(mealPlanProvider.notifier).generateNewPlan(),
      ),
      _ActionTile(
        icon: Icons.shopping_cart_outlined,
        label: 'Grocery List',
        color: AppColors.premiumCyanAccent,
        onTap: state.currentPlan != null
            ? () => context.go('/grocery')
            : null,
      ),
      if (isTablet && screenWidth >= 900)
        _ActionTile(
          icon: Icons.bolt,
          label: 'Quick Meal',
          color: AppColors.warmAccent,
          onTap: () => context.push('/quick-meal'),
        ),
    ];

    final tiles = actions.take(isTablet && screenWidth >= 900 ? 3 : 2).toList();
    return Row(
      children: tiles
          .map((tile) => Padding(
                padding: EdgeInsets.only(
                  right: tiles.last == tile ? 0 : AppSpacing.sm,
                ),
                child: Expanded(child: tile),
              ))
          .toList(),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PremiumCard(
        variant: PremiumCardVariant.accent,
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline,
                    color: AppColors.error, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Failed to load plan',
                    style: AppTypography.bodyLarge.copyWith(
                      color: PremiumTheme.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: () =>
                    ref.read(mealPlanProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Generating your perfect week...',
              style: AppTypography.bodyLarge.copyWith(
                color: PremiumTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    WidgetRef ref,
    MealPlanState state,
  ) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Budget',
            style: AppTypography.titleLarge.copyWith(
              color: PremiumTheme.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            state.currentPlan != null
                ? '${state.meals.length} meals planned for the week.'
                : r'$142.85 for 24 grocery items, including 8 pantry ingredients already on hand.',
            style: AppTypography.bodyMedium.copyWith(
              color: PremiumTheme.textSecondary(context),
            ),
          ),
          if (state.currentPlan != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Replace',
                    icon: Icons.swap_horiz,
                    variant: GlassButtonVariant.outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tap a meal to swap')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GlassButton(
                    label: 'Regenerate',
                    icon: Icons.refresh,
                    onPressed: () =>
                        ref.read(mealPlanProvider.notifier).generateNewPlan(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _onMealTap(
    BuildContext context,
    WidgetRef ref,
    int index,
    Meal meal,
  ) {
    final plan = ref.read(mealPlanProvider).currentPlan;
    final entry = plan != null && plan.entries.length > index
        ? plan.entries[index]
        : null;
    context.push(
      '/meal-swap/$index/${meal.type}',
      extra: {
        'meal': meal,
        'entry': entry,
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: AppRadius.xl,
        elevated: true,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
