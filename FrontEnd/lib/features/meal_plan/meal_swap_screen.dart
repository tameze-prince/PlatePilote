import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/models/meal_plan.dart';
import 'meal_plan_provider.dart';
import 'meal_plan_repository.dart';

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
  List<_SwapOption> _alternatives = [];
  bool _isLoading = true;
  _SwapOption? _selectedMeal;

  @override
  void initState() {
    super.initState();
    _loadAlternatives();
  }

  Future<void> _loadAlternatives() async {
    setState(() => _isLoading = true);
    try {
      final entryId = widget.currentEntry?.id;
      if (entryId != null) {
        final repo = ref.read(mealPlanRepositoryProvider);
        final options = await repo.getSwapOptions(entryId, 10);
        setState(() {
          _alternatives = options.map((o) => _SwapOption.fromJson(o)).toList();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _alternatives = demoMeals.where((m) => m.type == widget.mealType).toList()
          .map((m) => _SwapOption(
                recipeId: m.recipeId,
                name: m.title,
                minutes: m.minutes,
                calories: m.kcal,
                imageUrl: m.imageUrl,
              ))
          .toList();
      if (_alternatives.isEmpty) {
        _alternatives = demoMeals.map((m) => _SwapOption(
              recipeId: m.recipeId,
              name: m.title,
              minutes: m.minutes,
              calories: m.kcal,
              imageUrl: m.imageUrl,
            )).toList();
      }
      _isLoading = false;
    });
  }

  Future<void> _swapMeal() async {
    if (_selectedMeal == null) return;
    if (widget.currentEntry?.id != null && _selectedMeal!.recipeId != null) {
      try {
        final repo = ref.read(mealPlanRepositoryProvider);
        await repo.applySwap(widget.currentEntry!.id!, _selectedMeal!.recipeId!);
        await ref.read(mealPlanProvider.notifier).refresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meal swapped successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (_) {
        final newEntry = MealPlanEntry(
          recipeId: _selectedMeal!.recipeId,
          recipeName: _selectedMeal!.name,
          mealDate: widget.currentEntry!.mealDate,
          mealType: widget.mealType,
          servings: widget.currentEntry!.servings,
        );
        await ref
            .read(mealPlanProvider.notifier)
            .replaceEntry(widget.dayIndex, newEntry);
      }
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
                          '${widget.currentMeal.minutes} min \u2022 ${widget.currentMeal.kcal} kcal',
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
                                    color: tint.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                  child: Icon(icon, color: tint, size: 22),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal.name,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: PremiumTheme.textPrimary(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${meal.minutes ?? "?"} min \u2022 ${meal.calories ?? "?"} kcal',
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

class _SwapOption {
  final String? recipeId;
  final String name;
  final int? minutes;
  final int? calories;
  final String? imageUrl;

  _SwapOption({
    this.recipeId,
    required this.name,
    this.minutes,
    this.calories,
    this.imageUrl,
  });

  factory _SwapOption.fromJson(Map<String, dynamic> json) {
    return _SwapOption(
      recipeId: json['recipeId']?.toString(),
      name: json['name'] as String? ?? 'Unknown',
      minutes: json['totalTimeMinutes'] as int?,
      calories: json['caloriesPerServing'] as int?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
