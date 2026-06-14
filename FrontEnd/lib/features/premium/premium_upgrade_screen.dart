import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'subscription_provider.dart';

/// Écran de promotion et d'achat de l'abonnement Premium.
class PremiumUpgradeScreen extends ConsumerWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final l10n = AppLocalizations.of(context)!;

    return PlateScaffold(
      title: 'Premium',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            color: context.isDark
                ? AppColors.darkSurfaceContainerHigh
                : AppColors.surfaceContainerLow,
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
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '7 jours gratuits',
                        style: context.text.labelMedium?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Icon(
                  Icons.workspace_premium,
                  color: AppColors.secondary,
                  size: 42,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.unlockSmarter,
                  style: context.text.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.premiumSubtitle,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.text.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.perMonth(r'\$6.99'),
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
              children: [
                Expanded(
                  child: _PremiumFeature(
                    icon: Icons.auto_awesome,
                    title: l10n.aiPlanRegen,
                    subtitle: l10n.aiPlanRegenSub,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _PremiumFeature(
                    icon: Icons.document_scanner_outlined,
                    title: l10n.unlimitedScans,
                    subtitle: l10n.unlimitedScansSub,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _PremiumFeature(
                    icon: Icons.savings_outlined,
                    title: l10n.savingsIntelligence,
                    subtitle: l10n.savingsIntelligenceSub,
                  ),
                ),
              ],
            )
          else ...[
            _PremiumFeature(
              icon: Icons.auto_awesome,
              title: l10n.aiPlanRegen,
              subtitle: l10n.aiPlanRegenSub,
            ),
            _PremiumFeature(
              icon: Icons.document_scanner_outlined,
              title: l10n.unlimitedScans,
              subtitle: l10n.unlimitedScansSub,
            ),
            _PremiumFeature(
              icon: Icons.savings_outlined,
              title: l10n.savingsIntelligence,
              subtitle: l10n.savingsIntelligenceSub,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // ── Social Proof Stats ──
          AppCard(
            color: context.isDark
                ? AppColors.darkSurfaceContainerHigh
                : AppColors.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(value: '12,847', label: l10n.activeUsers),
                const _StatDivider(),
                _StatItem(value: '50,000+', label: 'repas planifiés'),
                const _StatDivider(),
                _StatItem(value: '4.8 ★', label: l10n.appRating),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Testimonials ──
          AppCard(
            color: context.isDark
                ? AppColors.darkSurfaceContainerHigh
                : AppColors.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TestimonialItem(
                  avatar: 'M',
                  name: 'Marie K.',
                  text: l10n.testimonial1Text,
                  rating: 5,
                ),
                SizedBox(height: AppSpacing.md),
                _TestimonialItem(
                  avatar: 'J',
                  name: 'Jean-Pierre D.',
                  text: l10n.testimonial2Text,
                  rating: 5,
                ),
                SizedBox(height: AppSpacing.md),
                _TestimonialItem(
                  avatar: 'A',
                  name: 'Aminata N.',
                  text: l10n.testimonial3Text,
                  rating: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Trust Badges ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _TrustBadge(icon: Icons.lock_outline, label: 'Paiement sécurisé'),
              SizedBox(width: AppSpacing.md),
              const _TrustBadge(icon: Icons.verified_outlined, label: 'Annulation facile'),
              SizedBox(width: AppSpacing.md),
              const _TrustBadge(icon: Icons.credit_card_off_outlined, label: 'Sans engagement'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: l10n.startTrial,
            icon: Icons.arrow_forward,
            onPressed: () async {
              final url = await ref.read(subscriptionProvider.notifier).createCheckoutSession();
              if (url != null && context.mounted) {
                await launchUrl(Uri.parse(url));
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.error)),
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
            Icon(icon, color: AppColors.primaryLight),
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

/// Widget pour afficher une statistique dans la section social proof.
class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.text.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryLight,
          ),
        ),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: context.text.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Séparateur vertical entre statistiques.
class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: context.isDark
          ? AppColors.darkOutline
          : AppColors.outline,
    );
  }
}

/// Widget pour afficher un témoignage utilisateur.
class _TestimonialItem extends StatelessWidget {
  const _TestimonialItem({
    required this.avatar,
    required this.name,
    required this.text,
    required this.rating,
  });

  final String avatar;
  final String name;
  final String text;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
          child: Text(
            avatar,
            style: TextStyle(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < rating ? Icons.star : Icons.star_outline,
                        size: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                text,
                style: context.text.bodySmall?.copyWith(
                  color: context.text.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Badge de confiance (icône + texte).
class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: context.text.bodyMedium?.color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: context.text.bodyMedium?.color,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}