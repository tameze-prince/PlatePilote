import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../shared/models/demo_data.dart';

class MealSwapScreen extends ConsumerStatefulWidget {
  final Meal currentMeal;
  final int dayIndex;
  final String mealType;

  const MealSwapScreen({
    super.key,
    required this.currentMeal,
    required this.dayIndex,
    required this.mealType,
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
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _alternatives = [
        const Meal(
          day: 'Mon',
          type: 'Dinner',
          title: 'Mediterranean Quinoa Bowl',
          minutes: 15,
          kcal: 450,
          icon: Icons.rice_bowl,
          tint: Color(0xFF22C55E),
        ),
        const Meal(
          day: 'Mon',
          type: 'Dinner',
          title: 'Grilled Chicken Salad',
          minutes: 20,
          kcal: 380,
          icon: Icons.set_meal,
          tint: Color(0xFF3B82F6),
        ),
        const Meal(
          day: 'Mon',
          type: 'Dinner',
          title: 'Vegetable Stir Fry',
          minutes: 18,
          kcal: 320,
          icon: Icons.dinner_dining,
          tint: Color(0xFFF59E0B),
        ),
        const Meal(
          day: 'Mon',
          type: 'Dinner',
          title: 'Lentil Soup',
          minutes: 25,
          kcal: 290,
          icon: Icons.soup_kitchen,
          tint: Color(0xFFEF4444),
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _swapMeal() async {
    if (_selectedMeal == null) return;
    if (context.mounted) {
      Navigator.pop(context, _selectedMeal);
    }
  }

  Future<void> _regenerateAll() async {
    if (context.mounted) {
      Navigator.pop(context, 'regenerate_all');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap Meal'),
        actions: [
          TextButton.icon(
            onPressed: _regenerateAll,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Regenerate All'),
            style: TextButton.styleFrom(
              foregroundColor: ColorTokens.primaryGreen,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: ColorTokens.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: widget.currentMeal.tint.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.input),
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
                        style: context.text.bodySmall?.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                      ),
                      Text(
                        widget.currentMeal.title,
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.currentMeal.minutes} min • ${widget.currentMeal.kcal} kcal',
                        style: context.text.bodySmall?.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_downward,
                  color: ColorTokens.textSecondary,
                ),
              ],
            ),
          ),
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
                                ? ColorTokens.primaryGreen.withOpacity(0.1)
                                : ColorTokens.surface,
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            border: Border.all(
                              color: isSelected
                                  ? ColorTokens.primaryGreen
                                  : ColorTokens.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: meal.tint.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Icon(
                                  meal.icon,
                                  color: meal.tint,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal.title,
                                      style: context.text.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${meal.minutes} min • ${meal.kcal} kcal',
                                      style: context.text.bodySmall?.copyWith(
                                        color: ColorTokens.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: ColorTokens.primaryGreen,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: ColorTokens.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: 'Swap Meal',
                    onPressed: _selectedMeal != null ? _swapMeal : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
