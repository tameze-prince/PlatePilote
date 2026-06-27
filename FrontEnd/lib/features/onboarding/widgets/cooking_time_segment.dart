import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/design_system/tokens/ds_radius.dart';
import '../../../core/design_system/tokens/ds_spacing.dart';
import '../../../core/design_system/tokens/ds_typography.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/premium_components.dart';
import '../onboarding_state.dart';

const List<int> _cookingMinutes = [15, 30, 45];

class CookingTimeSegment extends StatelessWidget {
  const CookingTimeSegment({
    super.key,
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
        const items = 4;
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

class _BudgetChip extends StatelessWidget {
  const _BudgetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
