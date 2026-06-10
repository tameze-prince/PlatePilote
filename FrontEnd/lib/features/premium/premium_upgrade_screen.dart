import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'subscription_provider.dart';

/// Écran de promotion et d'achat de l'abonnement Premium.
class PremiumUpgradeScreen extends ConsumerWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

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
                // Trial badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTokens.accentAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ColorTokens.accentAmber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: ColorTokens.accentAmber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '7 jours gratuits',
                        style: context.text.labelMedium?.copyWith(
                          color: ColorTokens.accentAmber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Annulez à tout moment. Essai gratuit inclus.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.text.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isTablet)
            Row(
              children: const [
                Expanded(
                  child: _PremiumFeature(
                    icon: Icons.auto_awesome,
                    title: 'AI plan regeneration',
                    subtitle:
                        'Swap meals while preserving budget and nutrition.',
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _PremiumFeature(
                    icon: Icons.document_scanner_outlined,
                    title: 'Unlimited pantry scans',
                    subtitle:
                        'Receipt, barcode, and camera-driven pantry capture.',
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _PremiumFeature(
                    icon: Icons.savings_outlined,
                    title: 'Savings intelligence',
                    subtitle:
                        'Track waste reduction and best-value substitutions.',
                  ),
                ),
              ],
            )
          else ...[
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
          ],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Commencer mon essai gratuit',
            icon: Icons.arrow_forward,
            onPressed: () async {
              final url = await ref.read(subscriptionProvider.notifier).createCheckoutSession();
              if (url != null && context.mounted) {
                await launchUrl(Uri.parse(url));
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to start checkout')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Widget d'affichage d'une fonctionnalité Premium.
class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  /// Icône de la fonctionnalité.
  final IconData icon;
  /// Titre de la fonctionnalité.
  final String title;
  /// Sous-titre descriptif.
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
