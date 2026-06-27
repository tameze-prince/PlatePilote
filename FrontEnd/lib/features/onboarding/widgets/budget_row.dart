import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/design_system/tokens/ds_radius.dart';
import '../../../core/design_system/tokens/ds_spacing.dart';
import '../../../core/design_system/tokens/ds_typography.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/premium_components.dart';
import '../onboarding_flow.dart' show showCustomBudgetSheet;
import '../onboarding_state.dart';

/// Brisure de la plage "Custom" pour reconnaître la saisie utilisateur.
const String kCustomBudgetSentinel = 'Custom';

/// Plates-formes de budget par paliers (clé technique → libellé utilisateur).
const List<(String, String)> _budgetPresets = [
  (r'$75', r'$75'),
  (r'$120', r'$120'),
  (r'$180', r'$180'),
];

/// Ligne horizontale des budgets prédéfinis + option "Custom".
class BudgetRow extends StatelessWidget {
  const BudgetRow({
    super.key,
    required this.state,
    required this.notifier,
  });

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
        selectedPreset == kCustomBudgetSentinel;

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
    notifier.setWeeklyBudget(kCustomBudgetSentinel);
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
