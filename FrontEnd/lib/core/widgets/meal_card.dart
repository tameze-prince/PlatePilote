import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../shared/models/demo_data.dart';
import 'app_card.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    required this.meal,
    this.compact = false,
    this.onTap,
    super.key,
  });

  final Meal meal;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 56.0 : 72.0;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: size,
              height: size,
              child: meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                  ? Image.network(
                      meal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _mealIcon(context),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : _mealIcon(context),
                    )
                  : _mealIcon(context),
            ),
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  meal.title,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
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

  Widget _mealIcon(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: meal.tint.withValues(alpha: context.isDark ? 0.24 : 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(meal.icon, color: meal.tint, size: compact ? 26 : 32),
    );
  }
}
