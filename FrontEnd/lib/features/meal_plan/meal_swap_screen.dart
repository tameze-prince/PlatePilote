import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/repositories/recipe_repository.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/models/meal_plan.dart';
import 'meal_plan_provider.dart';

class MealSwapScreen extends ConsumerStatefulWidget {
  final Meal currentMeal;
  final int dayIndex;
  final String mealType;
  final MealPlanEntry? currentEntry;

  const MealSwapScreen({
    super.key,
    required this.currentMeal,
    required this.dayIndex,
    required this.mealType,
    this.currentEntry,
  });

  @override
  ConsumerState<MealSwapScreen> createState() => _MealSwapScreenState();
}

class _MealSwapScreenState extends ConsumerState<MealSwapScreen> {
  List<Meal> _alternatives = [];
  bool _isLoading = true;
  Meal? _selectedMeal;

  @override
  void initState() {
    super.initState();
    _loadAlternatives();
  }

  Future<void> _loadAlternatives() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(recipeRepositoryProvider);
      final page = await repo.getByMealType(widget.mealType, size: 20);
      setState(() {
        _alternatives = page.content.map((detail) {
          IconData icon = Icons.restaurant;
          Color tint = Colors.green;
          switch (widget.mealType.toLowerCase()) {
            case 'breakfast':
              icon = Icons.wb_sunny; tint = Colors.orange; break;
            case 'lunch':
              icon = Icons.lunch_dining; tint = Colors.amber; break;
            case 'dinner':
              icon = Icons.dinner_dining; tint = Colors.deepPurple; break;
            case 'snack':
              icon = Icons.cookie; tint = Colors.brown; break;
          }
          return Meal(
            day: '',
            type: widget.mealType,
            title: detail.name ?? 'Unknown',
            minutes: detail.totalTimeMinutes ??
                ((detail.prepTimeMinutes ?? 0) + (detail.cookTimeMinutes ?? 0)),
            kcal: detail.caloriesPerServing ?? 450,
            icon: icon,
            tint: tint,
            imageUrl: detail.imageUrl,
            recipeId: detail.id,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _alternatives = demoMeals.where((m) => m.type == widget.mealType).toList();
        if (_alternatives.isEmpty) _alternatives = demoMeals;
        _isLoading = false;
      });
    }
  }

  Future<void> _swapMeal() async {
    if (_selectedMeal == null) return;
    if (widget.currentEntry != null && _selectedMeal!.recipeId != null) {
      final newEntry = MealPlanEntry(
        recipeId: _selectedMeal!.recipeId,
        recipeName: _selectedMeal!.title,
        mealDate: widget.currentEntry!.mealDate,
        mealType: widget.mealType,
        servings: widget.currentEntry!.servings,
      );
      await ref
          .read(mealPlanProvider.notifier)
          .replaceEntry(widget.dayIndex, newEntry);
    }
    if (context.mounted) context.pop();
  }

  Future<void> _regenerateAll() async {
    await ref.read(mealPlanProvider.notifier).generateNewPlan();
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Swap Meal',
                      style: AppTypography.titleLarge.copyWith(
                        color: PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _regenerateAll,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Regenerate All'),
                    ),
                  ],
                ),
              ),
            ),
            GlassContainer(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.xl,
              elevated: true,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: widget.currentMeal.tint.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      widget.currentMeal.icon,
                      color: widget.currentMeal.tint,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current ${widget.mealType}',
                          style: AppTypography.bodySmall.copyWith(
                            color: PremiumTheme.textTertiary(context),
                          ),
                        ),
                        Text(
                          widget.currentMeal.title,
                          style: AppTypography.titleMedium.copyWith(
                            color: PremiumTheme.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.currentMeal.minutes} min • ${widget.currentMeal.kcal} kcal',
                          style: AppTypography.bodySmall.copyWith(
                            color: PremiumTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_downward,
                    color: AppColors.primaryAccentGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Choose an alternative',
                style: AppTypography.titleMedium.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      itemCount: _alternatives.length,
                      itemBuilder: (context, index) {
                        final meal = _alternatives[index];
                        final isSelected = _selectedMeal == meal;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedMeal = meal);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryAccentGreen.withOpacity(0.12)
                                  : PremiumTheme.glass(context, elevated: true),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryAccentGreen
                                    : PremiumTheme.border(context),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: meal.tint.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                  child: Icon(
                                    meal.icon,
                                    color: meal.tint,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal.title,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: PremiumTheme.textPrimary(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${meal.minutes} min • ${meal.kcal} kcal',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: PremiumTheme.textSecondary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primaryAccentGreen,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Cancel',
                      variant: GlassButtonVariant.outlined,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Swap Meal',
                      onPressed: _selectedMeal != null ? _swapMeal : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
