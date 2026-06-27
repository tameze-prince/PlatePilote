import 'package:flutter/material.dart';

import '../../../core/design_system/components/pp_chip.dart';
import '../../../core/design_system/tokens/ds_spacing.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../onboarding_state.dart';

class GoalOption {
  const GoalOption(this.key, this.labelBuilder);
  final String key;
  final String Function(AppLocalizations) labelBuilder;
}

final List<GoalOption> _goalOptions = [
  GoalOption('Save money', (l) => l.onboardingSingleGoalSaveMoney),
  GoalOption('Eat healthier', (l) => l.onboardingSingleGoalEatHealthier),
  GoalOption('Waste less', (l) => l.onboardingSingleGoalWasteLess),
  GoalOption('Cook faster', (l) => l.onboardingSingleGoalCookFaster),
];

class GoalChips extends StatelessWidget {
  const GoalChips({
    super.key,
    required this.state,
    required this.notifier,
  });

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
