import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/components/pp_card.dart';
import '../../../core/design_system/tokens/ds_spacing.dart';
import '../../../core/design_system/tokens/ds_typography.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/premium_components.dart';

/// Grille 2x2 pour les profils culinaires (Beginner, Balanced, Batch cook,
/// Chef mode).
class CookingProfileGrid extends StatelessWidget {
  const CookingProfileGrid({
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
