import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/premium_components.dart';
import '../../../l10n/app_localizations.dart';
import 'premium_funnel_provider.dart';

/// Étape 2 — Pick plan : choix Monthly vs Annual.
///
/// Toggle unique Monthly ↔ Annual qui réajuste les 2 cards.
/// Affiche aussi features, social proof et trial copy.
class PickPlanStep extends ConsumerWidget {
  const PickPlanStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final funnel = ref.watch(premiumFunnelProvider);
    final notifier = ref.read(premiumFunnelProvider.notifier);

    return Stack(
      children: [
        const PremiumBackground(child: SizedBox.expand()),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.funnelPickPlanTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.4,
                    color: PremiumTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Toggle Monthly ↔ Annual
                _BillingToggle(
                  selected: funnel.planChoice,
                  onChanged: notifier.selectPlan,
                ),
                const SizedBox(height: AppSpacing.md),

                // 2 cartes de pricing
                Row(
                  children: [
                    Expanded(
                      child: _PlanCard(
                        title: l10n.funnelMonthlyTitle,
                        price: l10n.funnelMonthlyPrice,
                        per: l10n.funnelPerMonth,
                        selected: funnel.planChoice == PlanChoice.monthly,
                        isRecommended: false,
                        onTap: () => notifier.selectPlan(PlanChoice.monthly),
                        badgeLabel: l10n.funnelMonthlyTag,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _PlanCard(
                        title: l10n.funnelAnnualTitle,
                        price: l10n.funnelAnnualPrice,
                        per: '~${l10n.funnelAnnualEquiv}',
                        selected: funnel.planChoice == PlanChoice.annual,
                        isRecommended: true,
                        onTap: () => notifier.selectPlan(PlanChoice.annual),
                        badgeLabel: l10n.funnelSaveBadge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Features list
                _FeaturesList(),
                const SizedBox(height: AppSpacing.lg),

                // Social proof
                _SocialProof(),
                const SizedBox(height: AppSpacing.xl),

                // CTA Start trial
                GlassButton(
                  label: l10n.funnelCtaStartTrial,
                  icon: Icons.lock_open,
                  onPressed: notifier.next,
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    l10n.funnelTrialCopy,
                    style: TextStyle(
                      fontSize: 12,
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
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

/// Toggle Monthly ↔ Annual.
class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.selected, required this.onChanged});

  final PlanChoice selected;
  final ValueChanged<PlanChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMonthly = selected == PlanChoice.monthly;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: PremiumTheme.glass(context, elevated: true),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: PremiumTheme.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleChip(
              label: l10n.funnelMonthlyLabel,
              selected: isMonthly,
              onTap: () => onChanged(PlanChoice.monthly),
            ),
            _ToggleChip(
              label: l10n.funnelAnnualLabel,
              selected: !isMonthly,
              onTap: () => onChanged(PlanChoice.annual),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF00C896);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected
                ? Colors.white
                : PremiumTheme.textPrimary(context),
          ),
        ),
      ),
    );
  }
}

/// Carte de plan individuelle.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.per,
    required this.selected,
    required this.isRecommended,
    required this.onTap,
    required this.badgeLabel,
  });

  final String title;
  final String price;
  final String per;
  final bool selected;
  final bool isRecommended;
  final VoidCallback onTap;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF00C896);
    final bgColor = selected
        ? accent
        : PremiumTheme.glass(context, elevated: true);
    final fg = selected
        ? Colors.white
        : PremiumTheme.textPrimary(context);
    final fgSub = selected
        ? Colors.white.withValues(alpha: 0.85)
        : PremiumTheme.textSecondary(context);

    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.03 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? accent : PremiumTheme.border(context),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? PremiumTheme.glow(context, color: accent)
                : PremiumTheme.softShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.25)
                        : accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: selected ? Colors.white : accent,
                    ),
                  ),
                ),
              if (isRecommended) const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                price,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: fg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                per,
                style: TextStyle(fontSize: 11, color: fgSub),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste des features incluses.
class _FeaturesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = [
      l10n.funnelFeatureAi,
      l10n.funnelFeatureGrocery,
      l10n.funnelFeatureBudget,
      l10n.funnelFeatureScans,
      l10n.funnelFeatureFamily,
    ];
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.funnelFeaturesTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textPrimary(context),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF00C896),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        color: PremiumTheme.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloc social proof (12 400 households + testimonials).
class _SocialProof extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_alt_outlined,
                color: Color(0xFF00C896),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.funnelSocialProof,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _MiniTestimonial(text: l10n.testimonial1Text),
          const SizedBox(height: AppSpacing.xs),
          _MiniTestimonial(text: l10n.testimonial2Text),
        ],
      ),
    );
  }
}

class _MiniTestimonial extends StatelessWidget {
  const _MiniTestimonial({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.format_quote,
          size: 14,
          color: Color(0xFF00C896),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: PremiumTheme.textSecondary(context),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
