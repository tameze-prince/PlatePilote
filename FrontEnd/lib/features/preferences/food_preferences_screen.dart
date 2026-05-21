import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import 'preferences_provider.dart';

class FoodPreferencesScreen extends ConsumerWidget {
  const FoodPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(editablePreferencesProvider);
    final notifier = ref.read(editablePreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const FloatingHeader(
                title: 'Food Preferences',
                subtitle: 'How PlatePilot personalizes your meals',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl,
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _IntelligenceSummary(prefs: prefs),
                    const SizedBox(height: AppSpacing.lg),
                    _PreferenceSection(
                      title: 'Household',
                      icon: Icons.people_outline,
                      children: [
                        _ChoiceGrid(
                          label: 'Household size',
                          values: const ['1', '2', '3', '4+'],
                          selected: {prefs.householdSize},
                          onSelected: notifier.setHouseholdSize,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PreferenceSection(
                      title: 'Budget',
                      icon: Icons.payments_outlined,
                      description: 'Used to optimize your weekly meal plans',
                      children: [
                        _ChoiceGrid(
                          label: 'Weekly budget',
                          values: const [r'$75', r'$120', r'$180', 'Custom'],
                          selected: {prefs.weeklyBudget},
                          onSelected: notifier.setWeeklyBudget,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PreferenceSection(
                      title: 'Cooking',
                      icon: Icons.kitchen_outlined,
                      description: 'Helps match recipe complexity to your skill',
                      children: [
                        _ChoiceGrid(
                          label: 'Cooking skill',
                          values: const [
                            'Beginner',
                            'Balanced',
                            'Batch cook',
                            'Chef mode',
                          ],
                          selected: {prefs.cookingSkill},
                          onSelected: notifier.setCookingSkill,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ChoiceGrid(
                          label: 'Max cooking time',
                          values: const [
                            '15 min',
                            '30 min',
                            '45 min',
                            'Flexible',
                          ],
                          selected: {prefs.cookingTime},
                          onSelected: notifier.setCookingTime,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PreferenceSection(
                      title: 'Dietary Preferences',
                      icon: Icons.spa_outlined,
                      description: 'Improves grocery list accuracy',
                      children: [
                        _MultiChipGrid(
                          values: const [
                            'High protein',
                            'Vegetarian',
                            'Vegan',
                            'Gluten-free',
                            'Low carb',
                            'Keto',
                            'Dairy-free',
                            'Halal',
                          ],
                          selected: prefs.dietaryPreferences,
                          onSelected: notifier.toggleDietaryPreference,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PreferenceSection(
                      title: 'Allergies',
                      icon: Icons.warning_amber_rounded,
                      description: 'Helps PlatePilot avoid allergens',
                      children: [
                        _MultiChipGrid(
                          values: const [
                            'Peanuts',
                            'Tree nuts',
                            'Shellfish',
                            'Fish',
                            'Eggs',
                            'Soy',
                            'Lactose',
                            'Gluten',
                          ],
                          selected: prefs.allergies,
                          onSelected: notifier.toggleAllergy,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PreferenceSection(
                      title: 'Goals',
                      icon: Icons.flag_outlined,
                      description: 'Drives recommendation priorities',
                      children: [
                        _MultiChipGrid(
                          values: const [
                            'Save money',
                            'Eat healthier',
                            'Waste less',
                            'Cook faster',
                            'Lose weight',
                            'Gain muscle',
                          ],
                          selected: prefs.goals,
                          onSelected: notifier.toggleGoal,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PreferenceSection(
                      title: 'Preferred Cuisines',
                      icon: Icons.public,
                      description: 'Tailors recipe suggestions to your taste',
                      children: [
                        _MultiChipGrid(
                          values: const [
                            'Mediterranean',
                            'West African',
                            'French',
                            'Italian',
                            'Mexican',
                            'Japanese',
                            'Indian',
                            'American',
                          ],
                          selected: prefs.preferredCuisines,
                          onSelected: notifier.toggleCuisine,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }
}

class _IntelligenceSummary extends StatelessWidget {
  const _IntelligenceSummary({required this.prefs});

  final EditablePreferences prefs;

  @override
  Widget build(BuildContext context) {
    final summaries = <String>[];
    if (prefs.weeklyBudget.isNotEmpty) {
      summaries.add('Budget: ${prefs.weeklyBudget}/week');
    }
    if (prefs.cookingTime.isNotEmpty) {
      summaries.add('Prefers ${prefs.cookingTime} meals');
    }
    if (prefs.allergies.isNotEmpty) {
      summaries.add('Avoids: ${prefs.allergies.join(', ')}');
    }
    if (prefs.goals.isNotEmpty) {
      summaries.add('Goal: ${prefs.goals.first}');
    }

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      backgroundColor: AppColors.primaryAccentGreen.withOpacity(0.08),
      borderColor: AppColors.primaryAccentGreen.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primaryAccentGreen,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'PlatePilot Intelligence',
                style: AppTypography.titleMedium.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...summaries.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.primaryAccentGreen,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    s,
                    style: AppTypography.bodyMedium.copyWith(
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection({
    required this.title,
    required this.icon,
    this.description,
    required this.children,
  });

  final String title;
  final IconData icon;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: AppColors.primaryAccentGreen, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        color: PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: PremiumTheme.textTertiary(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: PremiumTheme.textSecondary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: values.map((v) {
            final isSelected = selected.contains(v);
            return _Chip(
              label: v,
              selected: isSelected,
              onTap: () => onSelected(v),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MultiChipGrid extends StatelessWidget {
  const _MultiChipGrid({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: values.map((v) {
        final isSelected = selected.contains(v);
        return _Chip(
          label: v,
          selected: isSelected,
          multiSelect: true,
          onTap: () => onSelected(v),
        );
      }).toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    this.multiSelect = false,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryAccentGreen
              : PremiumTheme.glass(context, elevated: true),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected
                ? AppColors.primaryAccentGreen
                : PremiumTheme.border(context),
          ),
          boxShadow: selected ? PremiumTheme.glow(context) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (multiSelect && selected)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xxs),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: PremiumTheme.isDark(context)
                      ? AppColors.darkBackground
                      : Colors.white,
                ),
              ),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: selected
                    ? (PremiumTheme.isDark(context)
                        ? AppColors.darkBackground
                        : Colors.white)
                    : PremiumTheme.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
