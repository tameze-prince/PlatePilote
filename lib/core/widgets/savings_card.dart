import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import 'app_card.dart';

class SavingsCard extends StatelessWidget {
  const SavingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Savings Summary',
            style: context.text.labelSmall?.copyWith(
              color: ColorTokens.primaryDark,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.micro),
          Text(
            r'$142.50',
            style: context.text.displaySmall?.copyWith(
              color: context.colors.primary,
            ),
          ),
          Text('Saved this month', style: context.text.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: ColorTokens.primaryDark,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.micro),
              Text(
                '12% more than last month',
                style: context.text.labelSmall?.copyWith(
                  color: ColorTokens.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
