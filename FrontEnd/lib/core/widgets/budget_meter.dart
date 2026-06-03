import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';

/// Indicateur de progression du budget avec une barre et un libellé.
class BudgetMeter extends StatelessWidget {
  const BudgetMeter({required this.progress, required this.caption, super.key});

  /// Progression en fraction (0.0 à 1.0).
  final double progress;

  /// Texte d'information affiché sous la barre.
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: progress,
            color: ColorTokens.primaryGreen,
            backgroundColor: context.isDark
                ? ColorTokens.darkElevatedSurface
                : ColorTokens.surfaceContainerLow,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(caption, style: context.text.bodyMedium),
      ],
    );
  }
}
