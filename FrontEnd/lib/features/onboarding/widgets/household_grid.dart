import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/components/pp_card.dart';
import '../../../core/design_system/tokens/ds_spacing.dart';
import '../../../core/design_system/tokens/ds_typography.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/premium_components.dart';

/// Grille 2 colonnes pour la taille du foyer (1, 2, 3, 4+).
class HouseholdSizeGrid extends StatelessWidget {
  const HouseholdSizeGrid({
    super.key,
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
