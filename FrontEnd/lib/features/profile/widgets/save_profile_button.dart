import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/premium_components.dart';

/// Bouton de sauvegarde du profil, visible uniquement s'il y a des
/// modifications non sauvegardées ou si la sauvegarde est en cours.
class SaveProfileButton extends StatelessWidget {
  const SaveProfileButton({
    super.key,
    required this.hasChanges,
    required this.saving,
    required this.onSave,
  });

  /// Vrai si des modifications non sauvegardées existent.
  final bool hasChanges;
  /// Vrai si la sauvegarde est en cours.
  final bool saving;
  /// Callback de sauvegarde.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    if (!hasChanges && !saving) return const SizedBox.shrink();
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      backgroundColor: AppColors.primaryAccentGreen.withValues(alpha: 0.08),
      borderColor: AppColors.primaryAccentGreen.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasChanges)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primaryAccentGreen,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'You have unsaved changes',
                      style: AppTypography.bodyMedium.copyWith(
                        color: PremiumTheme.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(saving ? 'Saving...' : 'Save All Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccentGreen,
                foregroundColor: PremiumTheme.isDark(context)
                    ? AppColors.darkBackground
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
