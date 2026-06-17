import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/premium_components.dart';
import '../../../l10n/app_localizations.dart';
import 'premium_funnel_provider.dart';

/// Étape 1 — Explain : proposition de valeur + bénéfices.
///
/// Affichée à l'ouverture du funnel. Doit convaincre en < 30 sec.
class ExplainStep extends ConsumerWidget {
  const ExplainStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        // Fond premium avec dégradé + glow ambiant.
        const PremiumBackground(child: SizedBox.expand()),

        // Bouton "Skip" collé en haut à droite.
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(
                right: AppSpacing.md,
                top: AppSpacing.xs,
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  foregroundColor: PremiumTheme.textSecondary(context),
                ),
                child: Text(l10n.funnelSkip),
              ),
            ),
          ),
        ),

        // Contenu scrollable centré.
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                _ExplainHero(),
                const SizedBox(height: AppSpacing.xl),
                _BenefitCard(
                  icon: Icons.auto_awesome,
                  title: l10n.funnelBenefitAiTitle,
                  subtitle: l10n.funnelBenefitAiSub,
                ),
                const SizedBox(height: AppSpacing.sm),
                _BenefitCard(
                  icon: Icons.shopping_basket_outlined,
                  title: l10n.funnelBenefitGroceryTitle,
                  subtitle: l10n.funnelBenefitGrocerySub,
                ),
                const SizedBox(height: AppSpacing.sm),
                _BenefitCard(
                  icon: Icons.savings_outlined,
                  title: l10n.funnelBenefitBudgetTitle,
                  subtitle: l10n.funnelBenefitBudgetSub,
                ),
                const SizedBox(height: AppSpacing.xl),
                GlassButton(
                  label: l10n.funnelCtaPickPlan,
                  icon: Icons.arrow_forward,
                  onPressed: () => ref
                      .read(premiumFunnelProvider.notifier)
                      .next(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Hero header (titre principal).
class _ExplainHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlowBadge(
          label: l10n.funnelTrialBadge,
          icon: Icons.star,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.funnelExplainTitle,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
          ).copyWith(color: PremiumTheme.textPrimary(context)),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.funnelExplainSubtitle,
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: PremiumTheme.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

/// Carte de bénéfice individuelle (icône + titre + sous-titre).
class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF00C896), size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: PremiumTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
