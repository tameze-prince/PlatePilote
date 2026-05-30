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
import '../../shared/widgets/shimmer_glass_skeleton.dart';
import '../grocery/grocery_provider.dart';
import 'meal_plan_provider.dart';
import 'meal_plan_repository.dart';

class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  ConsumerState<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen> {
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(mealPlanProvider.notifier).refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      extendBody: true,
      body: PremiumBackground(
        safeArea: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(mealPlanProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 80,
            ),
            children: [
              FloatingHeader(
                title: 'Your Week',
                subtitle: state.currentPlan != null
                    ? '${state.currentPlan!.startDate} – ${state.currentPlan!.endDate}${state.currentPlan!.status == 'ACTIVE' ? '  •  Saved' : ''}'
                    : 'Plan your meals',
                leading: state.availablePlans.length > 1
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _WeekArrow(
                            icon: Icons.chevron_left,
                            enabled: state.hasPrevPlan,
                            onTap: () => ref.read(mealPlanProvider.notifier).navigatePrev(),
                          ),
                          const SizedBox(width: 4),
                          _WeekArrow(
                            icon: Icons.chevron_right,
                            enabled: state.hasNextPlan,
                            onTap: () => ref.read(mealPlanProvider.notifier).navigateNext(),
                          ),
                        ],
                      )
                    : null,
                actions: [
                  IconButton(
                    onPressed: () => context.push('/plan-history'),
                    icon: const Icon(Icons.history),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _buildModeSelector(context, ref, state),
              const SizedBox(height: AppSpacing.md),
              _buildActionRow(context, ref, state, isTablet, screenWidth),
              const SizedBox(height: AppSpacing.md),
              if (state.error != null)
                _buildErrorCard(context, ref)
              else if (state.isLoading || state.isGenerating)
                _buildGlassSkeleton()
              else if (state.meals.isEmpty)
                _buildEmptyState(context, ref)
              else ...[
                _buildValueSummary(context, state),
                const SizedBox(height: AppSpacing.md),
                ..._buildGroupedMeals(context, ref, state),
                const SizedBox(height: AppSpacing.md),
                _buildBudgetCard(context, ref, state),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static const List<Map<String, String>> _modes = [
    {'key': 'STANDARD', 'label': 'Standard', 'icon': '⚖️'},
    {'key': 'WASTELESS', 'label': 'Waste Less', 'icon': '♻️'},
    {'key': 'ENDOFMONTH', 'label': 'End of Month', 'icon': '💰'},
    {'key': 'BUSYWEEK', 'label': 'Busy Week', 'icon': '⚡'},
    {'key': 'FAMILY', 'label': 'Family', 'icon': '👨‍👩‍👧‍👧'},
  ];

  Widget _buildModeSelector(BuildContext context, WidgetRef ref, MealPlanState state) {
    final currentMode = state.currentPlan?.mode ?? 'STANDARD';
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _modes.map((m) {
          final isActive = currentMode == m['key'];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child:             GestureDetector(
              onTap: () async {
                if (isActive) return;
                final planId = state.currentPlan?.id;
                if (planId != null) {
                  try {
                    final repo = ref.read(mealPlanRepositoryProvider);
                    await repo.setMode(planId, m['key']!);
                    await ref.read(mealPlanProvider.notifier).refresh();
                  } catch (_) {
                    await ref.read(mealPlanProvider.notifier)
                        .generateNewPlan(mode: m['key']!);
                  }
                } else {
                  await ref.read(mealPlanProvider.notifier)
                      .generateNewPlan(mode: m['key']!);
                }
              },
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm,
                ),
                borderRadius: AppRadius.full,
                elevated: isActive,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(m['icon']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      m['label']!,
                      style: AppTypography.labelSmall.copyWith(
                        color: isActive
                            ? AppColors.primaryAccentGreen
                            : PremiumTheme.textSecondary(context),
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildValueSummary(BuildContext context, MealPlanState state) {
    final cost = state.estimatedCost;
    final minutes = state.totalMinutes;
    final avgMinutes = state.meals.isEmpty ? 0 : (minutes / state.meals.length).round();

    return PremiumCard(
      variant: PremiumCardVariant.accent,
      child: Row(
        children: [
          Expanded(
            child: _ValueMetric(
              icon: Icons.restaurant_menu,
              label: 'Meals',
              value: '${state.meals.length}',
            ),
          ),
          Expanded(
            child: _ValueMetric(
              icon: Icons.schedule,
              label: 'Time',
              value: avgMinutes > 0 ? '$avgMinutes min avg' : 'Fast',
            ),
          ),
          Expanded(
            child: _ValueMetric(
              icon: Icons.savings_outlined,
              label: 'Estimate',
              value: cost > 0 ? '\$${cost.toStringAsFixed(0)}' : 'Budget',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSkeleton() {
    return Column(
      children: List.generate(7, (i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: ShimmerGlassSkeleton(
          width: double.infinity,
          height: 88,
        ),
      )),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    WidgetRef ref,
    MealPlanState state,
    bool isTablet,
    double screenWidth,
  ) {
    final isSaved = state.currentPlan?.status == 'ACTIVE';
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
        icon: isSaved ? Icons.check_circle : Icons.save_outlined,
        label: isSaved ? 'Saved' : 'Save Week',
        color: isSaved ? AppColors.primaryAccentGreen : AppColors.warmAccent,
        onTap: state.currentPlan != null && !state.isGenerating && !isSaved
            ? () async {
                await ref.read(mealPlanProvider.notifier).activatePlan();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal plan saved!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            : null,
      ),
      _ActionTile(
        icon: Icons.shopping_cart_outlined,
        label: 'Grocery List',
        color: AppColors.premiumCyanAccent,
        onTap: state.currentPlan != null
            ? () async {
                final planId = state.currentPlan?.id;
                if (planId != null) {
                  await ref.read(groceryProvider.notifier).generateFromMealPlan(planId);
                }
                if (context.mounted) context.go('/grocery');
              }
            : null,
      ),
    ];

    return Row(
      children: actions
          .map((tile) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: actions.last == tile ? 0 : AppSpacing.sm,
                  ),
                  child: tile,
                ),
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

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.restaurant_menu, size: 80,
              color: PremiumTheme.textSecondary(context).withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No meal plan yet',
            style: AppTypography.titleLarge.copyWith(
              color: PremiumTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Generate a weekly plan based on your preferences',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: PremiumTheme.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: 'Generate My First Plan',
            icon: Icons.auto_awesome,
            onPressed: () =>
                ref.read(mealPlanProvider.notifier).generateNewPlan(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedMeals(
    BuildContext context,
    WidgetRef ref,
    MealPlanState state,
  ) {
    const dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final grouped = <String, List<(int, Meal)>>{};
    for (final entry in state.meals.indexed) {
      grouped.putIfAbsent(entry.$2.day, () => []).add(entry);
    }
    final sortedDays = grouped.entries.toList()
      ..sort((a, b) => dayOrder.indexOf(a.key).compareTo(dayOrder.indexOf(b.key)));

    return [
      for (final dayGroup in sortedDays) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            _fullDayName(dayGroup.key),
            style: AppTypography.titleSmall.copyWith(
              color: PremiumTheme.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final entry in dayGroup.value)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Dismissible(
              key: ValueKey('meal_${entry.$2.recipeId}_${entry.$1}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                await ref.read(mealPlanProvider.notifier).removeEntry(entry.$1);
                return true;
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
              ),
              child: MealCard(
                meal: entry.$2,
                onTap: () => _onMealTap(context, ref, entry.$1, entry.$2),
                onSwap: entry.$2.recipeId != null
                    ? () => _onMealSwap(context, ref, entry.$1, entry.$2)
                    : null,
              ),
            ),
          ),
      ],
    ];
  }

  String _fullDayName(String abbrev) {
    switch (abbrev) {
      case 'Mon': return 'Monday';
      case 'Tue': return 'Tuesday';
      case 'Wed': return 'Wednesday';
      case 'Thu': return 'Thursday';
      case 'Fri': return 'Friday';
      case 'Sat': return 'Saturday';
      case 'Sun': return 'Sunday';
      default: return abbrev;
    }
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
            'Turn this plan into groceries',
            style: AppTypography.titleLarge.copyWith(
              color: PremiumTheme.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            state.currentPlan != null
                ? 'Generate a shopping list, subtract pantry items, and keep checkout tied to your weekly budget.'
                : 'Generate a plan first to unlock your optimized grocery list.',
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
                    label: 'Grocery',
                    icon: Icons.shopping_cart_outlined,
                    variant: GlassButtonVariant.outlined,
                    onPressed: () async {
                      final planId = state.currentPlan?.id;
                      if (planId != null) {
                        await ref.read(groceryProvider.notifier).generateFromMealPlan(planId);
                      }
                      if (context.mounted) context.go('/grocery');
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
    if (meal.recipeId != null) {
      context.push('/recipe/${meal.recipeId}');
    }
  }

  void _onMealSwap(
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

class _ValueMetric extends StatelessWidget {
  const _ValueMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryAccentGreen, size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.titleSmall.copyWith(
            color: PremiumTheme.textPrimary(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.labelSmall.copyWith(
            color: PremiumTheme.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _WeekArrow extends StatelessWidget {
  const _WeekArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.3,
        child: GlassContainer(
          padding: const EdgeInsets.all(6),
          borderRadius: AppRadius.full,
          child: Icon(icon, size: 18, color: PremiumTheme.textPrimary(context)),
        ),
      ),
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
