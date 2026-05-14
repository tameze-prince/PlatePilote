import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardingStep(
        title: 'Let us get to know your household',
        subtitle:
            'PlatePilot tunes portions, prep time, and budget around your kitchen.',
        progressLabel: 'Household setup',
        children: const [
          _ChoiceGrid(
            title: 'How many people do you usually cook for?',
            choices: ['1', '2', '3', '4+'],
            selected: 1,
          ),
          _ChoiceGrid(
            title: 'Cooking profile',
            choices: ['Quick', 'Balanced', 'Batch cook', 'Chef mode'],
            selected: 1,
          ),
        ],
      ),
      _OnboardingStep(
        title: 'Set your budget and boundaries',
        subtitle: 'Keep meals realistic without losing variety.',
        progressLabel: 'Budget & constraints',
        children: const [
          _ChoiceGrid(
            title: 'Weekly grocery budget',
            choices: [r'$75', r'$120', r'$180', 'Custom'],
            selected: 1,
          ),
          _ChoiceGrid(
            title: 'Dietary needs',
            choices: ['High protein', 'Vegetarian', 'Gluten-free', 'Low carb'],
            selected: 0,
          ),
        ],
      ),
      _OnboardingStep(
        title: 'Choose your goals',
        subtitle:
            'Optional pantry setup helps PlatePilot use what you already own.',
        progressLabel: 'Goals & pantry',
        children: const [
          _ChoiceGrid(
            title: 'Primary goal',
            choices: [
              'Save money',
              'Eat healthier',
              'Waste less',
              'Cook faster',
            ],
            selected: 0,
          ),
          _ChoiceGrid(
            title: 'Pantry import',
            choices: ['Scan receipt', 'Add staples', 'Skip for now'],
            selected: 1,
          ),
        ],
      ),
    ];

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
                  _ProgressHeader(step: step, label: pages[step].progressLabel),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(child: SingleChildScrollView(child: pages[step])),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: step == 2 ? 'Continue to sign in' : 'Continue',
                    onPressed: () {
                      if (step == 2) {
                        context.go('/login');
                      } else {
                        setState(() => step += 1);
                      }
                    },
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
    required this.progressLabel,
    required this.children,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
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
    required this.selected,
  });

  final String title;
  final List<String> choices;
  final int selected;

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
              final isSelected = index == selected;
              return AppCard(
                color: isSelected ? ColorTokens.primaryGreen : null,
                child: Center(
                  child: Text(
                    choices[index],
                    style: context.text.bodyLarge?.copyWith(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
