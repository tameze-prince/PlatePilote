import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/providers/app_session_provider.dart';
import 'onboarding_state.dart';

/// Écran principal du parcours d'onboarding en 3 étapes.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  /// Étape courante (0, 1 ou 2).
  int step = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final canContinue = switch (step) {
      0 => state.canContinueStepOne,
      1 => state.canContinueStepTwo,
      _ => state.canContinueStepThree,
    };

    return Scaffold(
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          child: Column(
            children: [
              const FloatingHeader(title: 'PlatePilot'),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: _ProgressHeader(step: step, label: _stepLabel(step)),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInOut,
                  child: SingleChildScrollView(
                    key: ValueKey(step),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    child: _buildStep(context, state, notifier),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    GlassButton(
                      label: step == 2 ? 'Continue to sign in' : 'Continue',
                      icon: Icons.arrow_forward,
                      onPressed: canContinue ? _continue : null,
                    ),
                    if (step > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      GlassOutlinedButton(
                        label: 'Back',
                        icon: Icons.arrow_back,
                        onPressed: () => setState(() => step -= 1),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Passe à l'étape suivante ou termine l'onboarding.
  Future<void> _continue() async {
    HapticFeedback.selectionClick();
    if (step == 2) {
      await ref.read(appSessionProvider.notifier).completeOnboarding();
      if (!mounted) return;
      final after = GoRouterState.of(context).uri.queryParameters['after'];
      context.go(after == 'signup' ? '/signup' : '/login');
      return;
    }
    setState(() => step += 1);
  }

  /// Construit le contenu de l'étape courante.
  Widget _buildStep(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    return switch (step) {
      0 => _OnboardingStep(
          title: 'Let us get to know your household',
          subtitle:
              'PlatePilot tunes portions, prep time, and budget around your kitchen.',
          children: [
            _ChoiceGrid(
              title: 'How many people do you usually cook for?',
              choices: const ['1', '2', '3', '4+'],
              selectedValues: {
                if (state.householdSize != null) state.householdSize!,
              },
              onSelected: notifier.setHouseholdSize,
            ),
            _ChoiceGrid(
              title: 'Cooking profile',
              choices: const ['Beginner', 'Balanced', 'Batch cook', 'Chef mode'],
              selectedValues: {
                if (state.cookingSkill != null) state.cookingSkill!,
              },
              onSelected: notifier.setCookingSkill,
            ),
          ],
        ),
      1 => _OnboardingStep(
          title: 'Set your budget and boundaries',
          subtitle: 'Keep meals realistic without losing variety.',
          children: [
            _ChoiceGrid(
              title: 'Weekly grocery budget',
              choices: const [r'$75', r'$120', r'$180', 'Custom'],
              selectedValues: {
                if (state.weeklyBudget != null) state.weeklyBudget!,
              },
              onSelected: notifier.setWeeklyBudget,
            ),
            _ChoiceGrid(
              title: 'Cooking time',
              choices: const ['15 min', '30 min', '45 min', 'Flexible'],
              selectedValues: {
                if (state.cookingTime != null) state.cookingTime!,
              },
              onSelected: notifier.setCookingTime,
            ),
            _ChoiceGrid(
              title: 'Dietary preferences',
              choices: const [
                'High protein',
                'Vegetarian',
                'Gluten-free',
                'Low carb',
              ],
              selectedValues: state.dietaryPreferences,
              onSelected: notifier.toggleDietaryPreference,
              multiSelect: true,
            ),
          ],
        ),
      _ => _OnboardingStep(
          title: 'Choose your goals',
          subtitle:
              'Optional pantry setup helps PlatePilot use what you already own.',
          children: [
            _ChoiceGrid(
              title: 'What should PlatePilot optimize for?',
              choices: const [
                'Save money',
                'Eat healthier',
                'Waste less',
                'Cook faster',
              ],
              selectedValues: state.goals,
              onSelected: notifier.toggleGoal,
              multiSelect: true,
            ),
            PremiumCard(
              variant: PremiumCardVariant.glass,
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primaryAccentGreen,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Pantry setup can be finished later from the Pantry tab.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: PremiumTheme.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    };
  }

  /// Libellé de l'étape courante.
  String _stepLabel(int step) => switch (step) {
        0 => 'Household setup',
        1 => 'Budget & constraints',
        _ => 'Goals & pantry',
      };
}

/// En-tête de progression avec barre de progression animée.
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.step, required this.label});

  /// Étape courante (0-indexée).
  final int step;
  /// Libellé de l'étape.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${step + 1} of 3',
              style: AppTypography.bodyMedium.copyWith(
                color: PremiumTheme.textSecondary(context),
              ),
            ),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primaryAccentGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedProgressBar(value: (step + 1) / 3),
      ],
    );
  }
}

/// Une étape de l'onboarding avec titre, sous-titre et contenu.
class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  /// Titre de l'étape.
  final String title;
  /// Sous-titre de l'étape.
  final String subtitle;
  /// Liste des widgets enfants.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          style: AppTypography.displaySmall.copyWith(
            color: PremiumTheme.textPrimary(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: PremiumTheme.textSecondary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...children,
      ],
    );
  }
}

/// Grille de choix pour une question de l'onboarding.
class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.title,
    required this.choices,
    required this.selectedValues,
    required this.onSelected,
    this.multiSelect = false,
  });

  /// Titre de la question.
  final String title;
  /// Liste des options disponibles.
  final List<String> choices;
  /// Ensemble des valeurs sélectionnées.
  final Set<String> selectedValues;
  /// Callback de sélection.
  final ValueChanged<String> onSelected;
  /// Vrai si la sélection multiple est autorisée.
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: PremiumTheme.textPrimary(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.25,
            ),
            itemCount: choices.length,
            itemBuilder: (context, index) {
              final value = choices[index];
              final selected = selectedValues.contains(value);
              return SelectableGlassCard(
                selected: selected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(value);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (multiSelect && selected) ...[
                      const Icon(Icons.check_circle, size: 18),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
