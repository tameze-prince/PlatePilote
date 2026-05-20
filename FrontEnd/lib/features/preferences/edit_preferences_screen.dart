import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'preferences_provider.dart';

class EditPreferencesScreen extends ConsumerWidget {
  const EditPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(editablePreferencesProvider);
    final notifier = ref.read(editablePreferencesProvider.notifier);

    return PlateScaffold(
      title: 'Edit Preferences',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _ChoiceSection(
            title: 'Household size',
            values: const ['1', '2', '3', '4+'],
            selected: {preferences.householdSize},
            onSelected: notifier.setHouseholdSize,
          ),
          _ChoiceSection(
            title: 'Cooking skill',
            values: const ['Beginner', 'Balanced', 'Batch cook', 'Chef mode'],
            selected: {preferences.cookingSkill},
            onSelected: notifier.setCookingSkill,
          ),
          _ChoiceSection(
            title: 'Weekly budget',
            values: const [r'$75', r'$120', r'$180', 'Custom'],
            selected: {preferences.weeklyBudget},
            onSelected: notifier.setWeeklyBudget,
          ),
          _ChoiceSection(
            title: 'Cooking time preference',
            values: const ['15 min', '30 min', '45 min', 'Flexible'],
            selected: {preferences.cookingTime},
            onSelected: notifier.setCookingTime,
          ),
          _ChoiceSection(
            title: 'Dietary preferences',
            values: const [
              'High protein',
              'Vegetarian',
              'Gluten-free',
              'Low carb',
            ],
            selected: preferences.dietaryPreferences,
            onSelected: notifier.toggleDietaryPreference,
            multiSelect: true,
          ),
          _ChoiceSection(
            title: 'Allergies',
            values: const ['Peanuts', 'Shellfish', 'Dairy', 'Soy'],
            selected: preferences.allergies,
            onSelected: notifier.toggleAllergy,
            multiSelect: true,
          ),
          _ChoiceSection(
            title: 'Goals',
            values: const [
              'Save money',
              'Eat healthier',
              'Waste less',
              'Cook faster',
            ],
            selected: preferences.goals,
            onSelected: notifier.toggleGoal,
            multiSelect: true,
          ),
          _ChoiceSection(
            title: 'Preferred cuisines',
            values: const [
              'Mediterranean',
              'West African',
              'French',
              'Mexican',
            ],
            selected: preferences.preferredCuisines,
            onSelected: notifier.toggleCuisine,
            multiSelect: true,
          ),
        ],
      ),
    );
  }
}

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.values,
    required this.selected,
    required this.onSelected,
    this.multiSelect = false,
  });

  final String title;
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onSelected;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final value in values)
                AppCard(
                  onTap: () => onSelected(value),
                  color: selected.contains(value)
                      ? ColorTokens.primaryGreen
                      : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (multiSelect && selected.contains(value)) ...[
                        const Icon(Icons.check, color: Colors.white, size: 16),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        value,
                        style: context.text.bodyLarge?.copyWith(
                          color: selected.contains(value) ? Colors.white : null,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
