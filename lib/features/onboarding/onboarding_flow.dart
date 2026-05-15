import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/providers/app_session_provider.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import 'onboarding_state.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
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
      appBar: AppBar(title: const Text('PlatePilot')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _ProgressHeader(step: step, label: _stepLabel(step)),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: SingleChildScrollView(
                        key: ValueKey(step),
                        child: _buildStep(context, state, notifier),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: step == 2 ? 'Continue to sign in' : 'Continue',
                    onPressed: canContinue
                        ? () async {
                            HapticFeedback.selectionClick();
                            if (step == 2) {
                              await ref
                                  .read(appSessionProvider.notifier)
                                  .completeOnboarding();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            } else {
                              setState(() => step += 1);
                            }
                          }
                        : null,
                  ),
                  if (step > 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    SecondaryButton(
                      label: 'Back',
                      icon: Icons.arrow_back,
                      onPressed: () => setState(() => step -= 1),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            selectedValues: {if (state.cookingTime != null) state.cookingTime!},
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
          AppCard(
            color: context.isDark
                ? ColorTokens.darkElevatedSurface
                : ColorTokens.surfaceContainerLow,
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Pantry setup can be finished later from the Pantry tab.',
                    style: context.text.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    };
  }

  String _stepLabel(int step) => switch (step) {
    0 => 'Household setup',
    1 => 'Budget & constraints',
    _ => 'Goals & pantry',
  };
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.step, required this.label});

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step ${step + 1} of 3', style: context.text.bodyMedium),
            Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          minHeight: 8,
          value: (step + 1) / 3,
          borderRadius: BorderRadius.circular(99),
          color: ColorTokens.primaryGreen,
          backgroundColor: context.isDark
              ? ColorTokens.darkElevatedSurface
              : ColorTokens.surfaceContainer,
        ),
      ],
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: context.text.bodyLarge?.copyWith(
            color: context.text.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...children,
      ],
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.title,
    required this.choices,
    required this.selectedValues,
    required this.onSelected,
    this.multiSelect = false,
  });

  final String title;
  final List<String> choices;
  final Set<String> selectedValues;
  final ValueChanged<String> onSelected;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.35,
            ),
            itemCount: choices.length,
            itemBuilder: (context, index) {
              final value = choices[index];
              final isSelected = selectedValues.contains(value);
              return AppCard(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(value);
                },
                color: isSelected ? ColorTokens.primaryGreen : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (multiSelect && isSelected) ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: context.text.bodyLarge?.copyWith(
                          color: isSelected ? Colors.white : null,
                          fontWeight: FontWeight.w700,
                        ),
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
