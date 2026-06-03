import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import 'preferences_provider.dart';

/// Écran des préférences alimentaires avec intelligence PlatePilot.
class FoodPreferencesScreen extends ConsumerStatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  ConsumerState<FoodPreferencesScreen> createState() =>
      _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState
    extends ConsumerState<FoodPreferencesScreen> {
  /// Indique si la sauvegarde est en cours.
  bool _saving = false;

  /// Sauvegarde les préférences via l'API.
  Future<void> _savePreferences() async {
    setState(() => _saving = true);
    try {
      await ref.read(editablePreferencesProvider.notifier).saveToApi();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              FloatingHeader(
                title: 'Food Preferences',
                subtitle: 'How PlatePilot personalizes your meals',
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccentGreen,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: PremiumTheme.glow(context),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: PremiumTheme.isDark(context)
                          ? AppColors.darkBackground
                          : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
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
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _savePreferences,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined, size: 18),
                        label: Text(_saving ? 'Saving...' : 'Save Preferences'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccentGreen,
                          foregroundColor: PremiumTheme.isDark(context)
                              ? AppColors.darkBackground
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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

/// Résumé intelligent des préférences actuelles de l'utilisateur.
class _IntelligenceSummary extends StatelessWidget {
  const _IntelligenceSummary({required this.prefs});

  /// Préférences éditables à résumer.
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

/// Section de préférences avec titre et icône.
class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection({
    required this.title,
    required this.icon,
    this.description,
    required this.children,
  });

  /// Titre de la section.
  final String title;
  /// Icône de la section.
  final IconData icon;
  /// Description optionnelle.
  final String? description;
  /// Widgets enfants.
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

/// Grille de choix mono-sélection.
class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  /// Libellé du groupe.
  final String label;
  /// Valeurs possibles.
  final List<String> values;
  /// Valeurs sélectionnées.
  final Set<String> selected;
  /// Callback de sélection.
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

/// Grille de chips multi-sélection.
class _MultiChipGrid extends StatelessWidget {
  const _MultiChipGrid({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  /// Valeurs possibles.
  final List<String> values;
  /// Valeurs sélectionnées.
  final Set<String> selected;
  /// Callback de sélection.
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

/// Chip interactif avec animation.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    this.multiSelect = false,
    required this.onTap,
  });

  /// Texte du chip.
  final String label;
  /// Vrai si sélectionné.
  final bool selected;
  /// Vrai si le chip est en mode multi-sélection.
  final bool multiSelect;
  /// Callback au tap.
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
