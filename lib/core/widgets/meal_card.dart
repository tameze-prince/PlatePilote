import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../shared/models/demo_data.dart';
import 'app_card.dart';

class MealCard extends StatelessWidget {
  const MealCard({required this.meal, this.compact = false, super.key});

  final Meal meal;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: compact ? 56 : 72,
            height: compact ? 56 : 72,
            decoration: BoxDecoration(
              color: meal.tint.withValues(alpha: context.isDark ? 0.24 : 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(meal.icon, color: meal.tint, size: compact ? 26 : 32),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  compact ? meal.type : meal.day,
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.micro),
                Text(
                  meal.title,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.micro),
                Text(
                  '${meal.kcal} kcal - ${meal.minutes} mins',
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            meal.locked ? Icons.lock_outline : Icons.more_vert,
            color: meal.locked
                ? ColorTokens.accentAmber
                : context.text.bodyMedium?.color,
          ),
        ],
      ),
    );
  }
}
