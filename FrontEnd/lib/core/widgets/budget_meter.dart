import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';

class BudgetMeter extends StatelessWidget {
  const BudgetMeter({required this.progress, required this.caption, super.key});

  final double progress;
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
