import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

enum ExpiryUrgency { none, fresh, soon, urgent, expired }

class ExpiryBadge extends StatelessWidget {
  const ExpiryBadge({
    required this.daysToExpiry,
    this.isExpired = false,
    super.key,
  });

  final int? daysToExpiry;
  final bool isExpired;

  ExpiryUrgency get urgency {
    if (isExpired || (daysToExpiry != null && daysToExpiry! < 0)) {
      return ExpiryUrgency.expired;
    }
    if (daysToExpiry == null) return ExpiryUrgency.none;
    if (daysToExpiry! <= 2) return ExpiryUrgency.urgent;
    if (daysToExpiry! <= 7) return ExpiryUrgency.soon;
    return ExpiryUrgency.fresh;
  }

  @override
  Widget build(BuildContext context) {
    if (urgency == ExpiryUrgency.none) return const SizedBox.shrink();

    final color = switch (urgency) {
      ExpiryUrgency.expired => AppColors.error,
      ExpiryUrgency.urgent => AppColors.error,
      ExpiryUrgency.soon => AppColors.warning,
      ExpiryUrgency.fresh => AppColors.primaryAccentGreen,
      ExpiryUrgency.none => AppColors.primaryAccentGreen,
    };
    final icon = switch (urgency) {
      ExpiryUrgency.expired => Icons.error_outline,
      ExpiryUrgency.urgent => Icons.priority_high_rounded,
      ExpiryUrgency.soon => Icons.schedule_rounded,
      ExpiryUrgency.fresh => Icons.check_circle_outline,
      ExpiryUrgency.none => Icons.event_available,
    };
    final label = switch (urgency) {
      ExpiryUrgency.expired => 'Expired',
      ExpiryUrgency.urgent => '${daysToExpiry}d',
      ExpiryUrgency.soon => '${daysToExpiry}d',
      ExpiryUrgency.fresh => '${daysToExpiry}d',
      ExpiryUrgency.none => '',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
