import 'package:flutter/material.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/widgets/plate_scaffold.dart';

class PremiumUpgradeScreen extends StatelessWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlateScaffold(
      title: 'Premium',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            color: context.isDark
                ? ColorTokens.darkElevatedSurface
                : ColorTokens.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: ColorTokens.accentAmber,
                  size: 42,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Unlock smarter meal planning',
                  style: context.text.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Advanced budget forecasting, unlimited pantry scans, family profiles, and deeper grocery savings.',
                  style: context.text.bodyLarge?.copyWith(
                    color: context.text.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  r'$6.99 / month',
                  style: context.text.displaySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _PremiumFeature(
            icon: Icons.auto_awesome,
            title: 'AI plan regeneration',
            subtitle: 'Swap meals while preserving budget and nutrition.',
          ),
          const _PremiumFeature(
            icon: Icons.document_scanner_outlined,
            title: 'Unlimited pantry scans',
            subtitle: 'Receipt, barcode, and camera-driven pantry capture.',
          ),
          const _PremiumFeature(
            icon: Icons.savings_outlined,
            title: 'Savings intelligence',
            subtitle: 'Track waste reduction and best-value substitutions.',
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Start Premium Trial',
            icon: Icons.arrow_forward,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AppCard(
        child: Row(
          children: [
            Icon(icon, color: ColorTokens.primaryGreen),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(subtitle, style: context.text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
