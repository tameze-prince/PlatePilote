import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/premium_components.dart';
import '../providers/profile_provider.dart';

/// Carte indiquant le taux de complétion du profil utilisateur.
class ProfileCompletenessCard extends ConsumerWidget {
  const ProfileCompletenessCard({super.key, required this.profile});

  /// Profil utilisateur observé.
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completeness = ref.watch(profileCompletenessProvider);
    if (completeness >= 1.0) return const SizedBox.shrink();

    final missingCount = 8 - profile.completeness;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      backgroundColor: AppColors.warning.withValues(alpha: 0.08),
      borderColor: AppColors.warning.withValues(alpha: 0.2),
      child: InkWell(
        onTap: () => _showMissingInfo(context, profile),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your profile',
                    style: AppTypography.bodyMedium.copyWith(
                      color: PremiumTheme.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$missingCount field${missingCount > 1 ? 's' : ''} missing for better recommendations',
                    style: AppTypography.bodySmall.copyWith(
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: PremiumTheme.textTertiary(context)),
          ],
        ),
      ),
    );
  }

  /// Affiche une boîte de dialogue avec la liste des champs manquants.
  void _showMissingInfo(BuildContext context, UserProfile profile) {
    final missing = <String>[];
    if (profile.gender == null) missing.add('Gender');
    if (profile.heightCm == null) missing.add('Height');
    if (profile.weightKg == null) missing.add('Weight');
    if (profile.dateOfBirth == null) missing.add('Date of Birth');
    if (profile.activityLevel == null) missing.add('Activity Level');
    if (profile.cookingSkill == null) missing.add('Cooking Skill');
    if (profile.householdSize == null) missing.add('Household Size');
    if (profile.healthGoals == null || profile.healthGoals!.isEmpty) {
      missing.add('Health Goals');
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Optimize Recommendations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fill in these fields to help PlatePilot\'s recommendation engine '
              'provide the best meal suggestions for you:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.md),
            ...missing.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record, size: 8, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Text(f, style: const TextStyle(fontSize: 14)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Fill Now'),
          ),
        ],
      ),
    );
  }
}
