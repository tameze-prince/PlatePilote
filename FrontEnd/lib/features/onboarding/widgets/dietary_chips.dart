import 'package:flutter/material.dart';

import '../../../core/design_system/components/pp_chip.dart';
import '../../../core/design_system/tokens/ds_spacing.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../onboarding_state.dart';

class DietaryOption {
  const DietaryOption(this.key, this.labelKey);
  final String key;
  final String Function(AppLocalizations) labelKey;
}

final List<DietaryOption> _dietaryOptions = [
  DietaryOption('Vegetarian', (l) => l.vegetarian),
  DietaryOption('Vegan', (l) => l.onboardingSingleVegan),
  DietaryOption('Halal', (l) => l.onboardingSingleHalal),
  DietaryOption('Gluten-free', (l) => l.glutenFree),
  DietaryOption('Lactose-free', (l) => l.onboardingSingleLactoseFree),
  DietaryOption('Keto', (l) => l.onboardingSingleKeto),
  DietaryOption('Low carb', (l) => l.lowCarb),
  DietaryOption('Pescatarian', (l) => l.onboardingSinglePescatarian),
];

class DietaryChips extends StatelessWidget {
  const DietaryChips({
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
