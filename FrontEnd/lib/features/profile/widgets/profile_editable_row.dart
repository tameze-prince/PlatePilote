import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/premium_components.dart';

/// Ligne éditable avec icône, label et valeur. Utilisée par `ProfileInfoCard`.
class ProfileEditableRow extends StatelessWidget {
  const ProfileEditableRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
  });

  /// Label du champ.
  final String label;
  /// Valeur affichée.
  final String value;
  /// Icône optionnelle.
  final IconData? icon;
  /// Callback de modification.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.primaryAccentGreen),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              flex: 2,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textTertiary(context),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 3,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTypography.bodyLarge.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: PremiumTheme.textTertiary(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
