import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_animations.dart';
import '../../app/theme/app_colors.dart';
import '../../core/design_system/components/pp_button.dart';
import '../../core/design_system/components/pp_card.dart';
import '../../core/design_system/components/pp_chip.dart';
import '../../core/design_system/components/pp_scaffold.dart';
import '../../core/design_system/tokens/ds_motion.dart';
import '../../core/design_system/tokens/ds_radius.dart';
import '../../core/design_system/tokens/ds_spacing.dart';
import '../../core/design_system/tokens/ds_typography.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/premium_components.dart';
import '../../core/providers/app_session_provider.dart';
import '../../l10n/app_localizations.dart';
import '../auth/providers/auth_provider.dart';
import 'onboarding_completion.dart';
import 'onboarding_flow.dart' show showCustomBudgetSheet;
import 'onboarding_state.dart';

/// Brisure de la plage "Custom" pour reconnaître la saisie utilisateur.
const String _kCustomBudgetSentinel = 'Custom';

/// Options prédéfinies pour la grille "household size".
const List<String> _householdChoices = ['1', '2', '3', '4+'];

/// Profils culinaires disponibles.
const List<String> _cookingProfiles = [
  'Beginner',
  'Balanced',
  'Batch cook',
  'Chef mode',
];

/// Plates-formes de budget par paliers (clé technique → libellé utilisateur).
const List<(String, String)> _budgetPresets = [
  (r'$75', r'$75'),
  (r'$120', r'$120'),
  (r'$180', r'$180'),
];

/// Temps de cuisson disponibles.
const List<int> _cookingMinutes = [15, 30, 45];

/// Préférence alimentaire exposée dans le single-screen.
class _DietaryOption {
  const _DietaryOption(this.key, this.labelKey);
  final String key;
  final String Function(AppLocalizations) labelKey;
}

final List<_DietaryOption> _dietaryOptions = [
  _DietaryOption('Vegetarian', (l) => l.vegetarian),
  _DietaryOption('Vegan', (l) => l.onboardingSingleVegan),
  _DietaryOption('Halal', (l) => l.onboardingSingleHalal),
  _DietaryOption('Gluten-free', (l) => l.glutenFree),
  _DietaryOption('Lactose-free', (l) => l.onboardingSingleLactoseFree),
  _DietaryOption('Keto', (l) => l.onboardingSingleKeto),
  _DietaryOption('Low carb', (l) => l.lowCarb),
  _DietaryOption('Pescatarian', (l) => l.onboardingSinglePescatarian),
];

/// Objectif exposé dans le single-screen.
class _GoalOption {
  const _GoalOption(this.key, this.labelBuilder);
  final String key;
  final String Function(AppLocalizations) labelBuilder;
}

final List<_GoalOption> _goalOptions = [
  _GoalOption('Save money', (l) => l.onboardingSingleGoalSaveMoney),
  _GoalOption('Eat healthier', (l) => l.onboardingSingleGoalEatHealthier),
  _GoalOption('Waste less', (l) => l.onboardingSingleGoalWasteLess),
  _GoalOption('Cook faster', (l) => l.onboardingSingleGoalCookFaster),
];

/// Onboarding "scroll-to-commit" : toutes les sections tiennent sur un seul
/// écran scrollable. Objectif : ramener le time-to-value sous 90 secondes.
class OnboardingSingleScreen extends ConsumerStatefulWidget {
  const OnboardingSingleScreen({super.key});

  @override
  ConsumerState<OnboardingSingleScreen> createState() =>
      _OnboardingSingleScreenState();
}

class _OnboardingSingleScreenState extends ConsumerState<OnboardingSingleScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final l10n = context.l10n!;
    final isAuthed = ref.watch(authProvider).isAuthenticated;

    return PpScaffold(
      body: Column(
        children: [
          _SingleScreenHeader(onCustomizeLater: () => _customizeLater()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                DsSpacing.lg,
                DsSpacing.sm,
                DsSpacing.lg,
                DsSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeading(
                    title: l10n.onboardingSingleHousehold,
                  ),
                  const SizedBox(height: DsSpacing.md),
                  _HouseholdGrid(
                    choices: _householdChoices,
                    selected: state.householdSize,
                    onSelected: notifier.setHouseholdSize,
                  ),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleCookingProfile),
                  const SizedBox(height: DsSpacing.md),
                  _CookingProfileGrid(
                    choices: _cookingProfiles,
                    selected: state.cookingSkill,
                    onSelected: notifier.setCookingSkill,
                  ),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleBudget),
                  const SizedBox(height: DsSpacing.md),
                  _BudgetRow(
                    state: state,
                    notifier: notifier,
                  ),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleTime),
                  const SizedBox(height: DsSpacing.md),
                  _CookingTimeSegmented(
                    state: state,
                    notifier: notifier,
                  ),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleDietary),
                  const SizedBox(height: DsSpacing.md),
                  _DietaryChips(
                    state: state,
                    notifier: notifier,
                  ),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleGoals),
                  const SizedBox(height: DsSpacing.md),
                  _GoalChips(
                    state: state,
                    notifier: notifier,
                  ),
                  const SizedBox(height: DsSpacing.xxl),
                  _LivePreviewCard(state: state),
                ],
              ),
            ),
          ),
          _BottomCta(
            enabled: state.householdSize != null,
            isAuthed: isAuthed,
            onSeePlan: () => _commit(notifier),
            onCreateAccount: () => _commitAndSignup(notifier),
            onSignInInstead: () => _customizeLater(),
          ),
        ],
      ),
    );
  }

  Future<void> _commit(OnboardingNotifier notifier) async {
    HapticFeedback.selectionClick();
    await notifier.flush();
    await ref.read(appSessionProvider.notifier).completeOnboarding();
    await notifier.clearDraft();
    if (!mounted) return;
    await OnboardingCompletion.commitAndGeneratePlan(
      ref: ref,
      context: context,
      onSuccess: () {
        if (!mounted) return;
        final isAuthed = ref.read(authProvider).isAuthenticated;
        context.go(isAuthed ? '/home' : '/login');
      },
    );
  }

  Future<void> _commitAndSignup(OnboardingNotifier notifier) async {
    HapticFeedback.selectionClick();
    await notifier.flush();
    if (!mounted) return;
    context.go('/onboarding?after=signup');
  }

  Future<void> _customizeLater() async {
    HapticFeedback.selectionClick();
    final isAuthed = ref.read(authProvider).isAuthenticated;
    context.go(isAuthed ? '/home' : '/login');
  }
}

/// Bandeau d'en-tête minimal (titre + sous-titre + lien "customize later").
class _SingleScreenHeader extends StatelessWidget {
  const _SingleScreenHeader({required this.onCustomizeLater});

  final VoidCallback onCustomizeLater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DsSpacing.lg,
        DsSpacing.md,
        DsSpacing.lg,
        DsSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingSingleTitle,
                  style: DsTypography.displaySmall.copyWith(
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: DsSpacing.xxs),
                Text(
                  l10n.onboardingSingleSubtitle,
                  style: DsTypography.bodyMedium.copyWith(
                    color: PremiumTheme.textSecondary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onCustomizeLater,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryAccentGreen,
              textStyle: DsTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(l10n.onboardingSingleCustomizeLater),
          ),
        ],
      ),
    );
  }
}

/// Titre de section avec typo headline_small.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: DsTypography.headlineSmall.copyWith(
        color: PremiumTheme.textPrimary(context),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

/// Grille 2 colonnes pour la taille du foyer.
class _HouseholdGrid extends StatelessWidget {
  const _HouseholdGrid({
    required this.choices,
    required this.selected,
    required this.onSelected,
  });

  final List<String> choices;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = DsSpacing.md;
        final width = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: choices.map((value) {
            final isSelected = value == selected;
            return SizedBox(
              width: width,
              child: PpCard(
                variant: PpCardVariant.glass,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(value);
                },
                padding: const EdgeInsets.symmetric(
                  vertical: DsSpacing.md,
                  horizontal: DsSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: DsTypography.headlineMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.xxs),
                    Text(
                      l10n.onboardingSingleHouseholdPeople(value),
                      style: DsTypography.labelSmall.copyWith(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.85)
                            : PremiumTheme.textSecondary(context),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Grille 2x2 pour les profils culinaires.
class _CookingProfileGrid extends StatelessWidget {
  const _CookingProfileGrid({
    required this.choices,
    required this.selected,
    required this.onSelected,
  });

  final List<String> choices;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final labels = {
      'Beginner': l10n.beginner,
      'Balanced': l10n.balanced,
      'Batch cook': l10n.batchCook,
      'Chef mode': l10n.chefMode,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = DsSpacing.md;
        final width = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: choices.map((value) {
            final isSelected = value == selected;
            return SizedBox(
              width: width,
              child: PpCard(
                variant: PpCardVariant.glass,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(value);
                },
                padding: const EdgeInsets.symmetric(
                  vertical: DsSpacing.md,
                  horizontal: DsSpacing.sm,
                ),
                child: Center(
                  child: Text(
                    labels[value] ?? value,
                    style: DsTypography.titleMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : PremiumTheme.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Ligne horizontale des budgets prédifinis + "Custom".
class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.state, required this.notifier});

  final OnboardingState state;
  final OnboardingNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final customAmountLabel = state.customBudget == null
        ? l10n.onboardingSingleCustom
        : '\$${state.customBudget!.toStringAsFixed(0)}';
    final selectedPreset = state.weeklyBudget;
    final customActive = state.customBudget != null ||
        selectedPreset == _kCustomBudgetSentinel;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = DsSpacing.sm;
        final width = (constraints.maxWidth - spacing * 3) / 4;
        return Row(
          children: [
            for (final preset in _budgetPresets)
              Padding(
                padding: const EdgeInsets.only(right: spacing),
                child: SizedBox(
                  width: width,
                  child: _BudgetChip(
                    label: preset.$2,
                    selected: selectedPreset == preset.$1 && !customActive,
                    onTap: () => notifier.setWeeklyBudget(preset.$1),
                  ),
                ),
              ),
            SizedBox(
              width: width,
              child: _BudgetChip(
                label: customAmountLabel,
                selected: customActive,
                iconLeading: Icons.tune,
                onTap: () => _pickCustom(context, notifier),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickCustom(
    BuildContext context,
    OnboardingNotifier notifier,
  ) async {
    HapticFeedback.selectionClick();
    notifier.setWeeklyBudget(_kCustomBudgetSentinel);
    final picked = await showCustomBudgetSheet(
      context,
      initial: state.customBudget,
    );
    if (picked != null) {
      notifier.setCustomBudget(picked);
    }
  }
}

/// Chip dédiée à un palier de budget (preset ou custom).
class _BudgetChip extends StatelessWidget {
  const _BudgetChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconLeading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? iconLeading;

  @override
  Widget build(BuildContext context) {
    final isDark = PremiumTheme.isDark(context);
    final background = selected
        ? AppColors.primaryAccentGreen
        : PremiumTheme.glass(context, elevated: true);
    final border = selected
        ? AppColors.primaryAccentGreen
        : PremiumTheme.border(context);
    final foreground = selected
        ? (isDark ? AppColors.darkBackground : Colors.white)
        : PremiumTheme.textPrimary(context);

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(DsRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DsRadius.full),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DsSpacing.sm,
              vertical: DsSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(DsRadius.full),
              border: Border.all(color: border),
              boxShadow: selected ? PremiumTheme.glow(context) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconLeading != null) ...[
                  Icon(iconLeading, size: 16, color: foreground),
                  const SizedBox(width: DsSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTypography.titleMedium.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sélecteur segmenté pour le temps de cuisson + option "Flexible".
class _CookingTimeSegmented extends StatelessWidget {
  const _CookingTimeSegmented({
    required this.state,
    required this.notifier,
  });

  final OnboardingState state;
  final OnboardingNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isFlexible = state.cookingTime == 'Flexible';
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = DsSpacing.xs;
        final items = 4;
        final width = (constraints.maxWidth - spacing * (items - 1)) / items;
        return Row(
          children: [
            for (final minutes in _cookingMinutes)
              Padding(
                padding: const EdgeInsets.only(right: spacing),
                child: SizedBox(
                  width: width,
                  child: _BudgetChip(
                    label: l10n.onboardingSingleTimeShort(minutes),
                    selected: state.cookingTime == '${minutes}min' ||
                        state.cookingTime == '$minutes min',
                    onTap: () => notifier.setCookingTime('$minutes min'),
                  ),
                ),
              ),
            SizedBox(
              width: width,
              child: _BudgetChip(
                label: l10n.onboardingSingleTimeFlexible,
                selected: isFlexible,
                onTap: () => notifier.setCookingTime('Flexible'),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Chips wrapping "Dietary preferences" — multi-select.
class _DietaryChips extends StatelessWidget {
  const _DietaryChips({required this.state, required this.notifier});

  final OnboardingState state;
  final OnboardingNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DsSpacing.sm,
      runSpacing: DsSpacing.sm,
      children: _dietaryOptions.map((option) {
        final selected = state.dietaryPreferences.contains(option.key);
        return PpChip(
          label: option.labelKey(context.l10n!),
          variant: PpChipVariant.filter,
          selected: selected,
          onPressed: () =>
              notifier.toggleDietaryPreference(option.key),
        );
      }).toList(),
    );
  }
}

/// Chips "Goals" — multi-select.
class _GoalChips extends StatelessWidget {
  const _GoalChips({required this.state, required this.notifier});

  final OnboardingState state;
  final OnboardingNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DsSpacing.sm,
      runSpacing: DsSpacing.sm,
      children: _goalOptions.map((goal) {
        final selected = state.goals.contains(goal.key);
        return PpChip(
          label: goal.labelBuilder(context.l10n!),
          variant: PpChipVariant.filter,
          selected: selected,
          icon: _iconFor(goal.key),
          onPressed: () => notifier.toggleGoal(goal.key),
        );
      }).toList(),
    );
  }

  IconData? _iconFor(String key) {
    return switch (key) {
      'Save money' => Icons.savings_outlined,
      'Eat healthier' => Icons.favorite_outline,
      'Waste less' => Icons.eco_outlined,
      'Cook faster' => Icons.flash_on_outlined,
      _ => null,
    };
  }
}

/// Carte "Your week" — résumé live des choix utilisateur.
class _LivePreviewCard extends StatelessWidget {
  const _LivePreviewCard({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDark = PremiumTheme.isDark(context);
    final hasHousehold = state.householdSize != null;
    final recipesPerWeek = _estimateRecipes(state);
    final budgetLabel = _formatBudget(state);
    final minutesLabel = _formatMinutes(state);

    return AnimatedSwitcher(
      duration: AppMotion.small,
      switchInCurve: AppAnimations.easeOutEmphasized,
      child: PpCard(
        key: ValueKey<String>('preview-$hasHousehold'),
        variant: PpCardVariant.glass,
        padding: const EdgeInsets.all(DsSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccentGreen.withValues(
                      alpha: isDark ? 0.18 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(DsRadius.md),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.primaryAccentGreen,
                  ),
                ),
                const SizedBox(width: DsSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.onboardingSinglePreviewTitle,
                    style: DsTypography.titleMedium.copyWith(
                      color: PremiumTheme.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DsSpacing.md),
            if (!hasHousehold)
              Text(
                l10n.onboardingSinglePreviewEmpty,
                style: DsTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textSecondary(context),
                ),
              )
            else ...[
              _PreviewLine(
                icon: Icons.restaurant_outlined,
                text: l10n.onboardingSinglePreviewRecipes(recipesPerWeek),
              ),
              const SizedBox(height: DsSpacing.xs),
              _PreviewLine(
                icon: Icons.payments_outlined,
                text: l10n.onboardingSinglePreviewBudget(budgetLabel),
              ),
              const SizedBox(height: DsSpacing.xs),
              _PreviewLine(
                icon: Icons.schedule_outlined,
                text: l10n.onboardingSinglePreviewTime(minutesLabel),
              ),
            ],
            const SizedBox(height: DsSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DsSpacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(DsRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: AppColors.primaryAccentGreen,
                  ),
                  const SizedBox(width: DsSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.onboardingSinglePreviewPantryHint,
                      style: DsTypography.bodySmall.copyWith(
                        color: PremiumTheme.textSecondary(context),
                      ),
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

  /// Estime grossièrement le nombre de recettes hebdomadaires selon le foyer.
  int _estimateRecipes(OnboardingState state) {
    final people = int.tryParse(
          state.householdSize!.replaceAll('+', ''),
        ) ??
        (state.householdSize == '4+' ? 5 : 2);
    // ~3 recettes/semaine/personne, bornée entre 5 et 21.
    final estimate = (people * 3).clamp(5, 21);
    return estimate;
  }

  String _formatBudget(OnboardingState state) {
    if (state.customBudget != null) {
      return '\$${state.customBudget!.toStringAsFixed(0)}';
    }
    final raw = state.weeklyBudget ?? r'$120';
    return raw.isEmpty ? r'$120' : raw;
  }

  int _formatMinutes(OnboardingState state) {
    final raw = state.cookingTime;
    if (raw == null || raw == 'Flexible') return 30;
    final digits = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
    return digits ?? 30;
  }
}

/// Ligne d'aperçu : icône + texte.
class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryAccentGreen),
        const SizedBox(width: DsSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: DsTypography.bodyMedium.copyWith(
              color: PremiumTheme.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// CTA bottom — "See your plan" si authentifié, sinon double CTA.
class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.enabled,
    required this.isAuthed,
    required this.onSeePlan,
    required this.onCreateAccount,
    required this.onSignInInstead,
  });

  final bool enabled;
  final bool isAuthed;
  final VoidCallback onSeePlan;
  final VoidCallback onCreateAccount;
  final VoidCallback onSignInInstead;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        DsSpacing.lg,
        DsSpacing.md,
        DsSpacing.lg,
        DsSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: PremiumTheme.background(context),
        border: Border(
          top: BorderSide(color: PremiumTheme.border(context)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: isAuthed
            ? PpButton(
                label: l10n.onboardingSingleCtaSeePlan,
                icon: Icons.arrow_forward,
                onPressed: enabled ? onSeePlan : null,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PpButton(
                    label: l10n.onboardingSingleCtaCreateAccount,
                    icon: Icons.rocket_launch_outlined,
                    onPressed: enabled ? onCreateAccount : null,
                  ),
                  const SizedBox(height: DsSpacing.sm),
                  PpButton(
                    label: l10n.onboardingSingleCtaSignInInstead,
                    variant: PpButtonVariant.ghost,
                    icon: Icons.login,
                    onPressed: onSignInInstead,
                  ),
                ],
              ),
      ),
    );
  }
}
