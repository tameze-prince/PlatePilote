import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/design_system/tokens/ds_spacing.dart';
import '../../../core/design_system/tokens/ds_typography.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/premium_components.dart';

/// Bandeau d'en-tête de l'écran d'onboarding unique :
/// titre principal + sous-titre + lien "customize later".
class OnboardingWelcomeHeader extends StatelessWidget {
  const OnboardingWelcomeHeader({super.key, required this.onCustomizeLater});

  final VoidCallback onCustomizeLater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DsSpacing.lg,
        DsSpacing.md,
        DsSpacing.lg,
        DsSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingSingleTitle,
                  style: DsTypography.displaySmall.copyWith(
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: DsSpacing.xxs),
                Text(
                  l10n.onboardingSingleSubtitle,
                  style: DsTypography.bodyMedium.copyWith(
                    color: PremiumTheme.textSecondary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onCustomizeLater,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryAccentGreen,
              textStyle: DsTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(l10n.onboardingSingleCustomizeLater),
          ),
        ],
      ),
    );
  }
}
