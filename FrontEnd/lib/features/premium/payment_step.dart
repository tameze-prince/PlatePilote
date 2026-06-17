import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/premium_components.dart';
import '../../../l10n/app_localizations.dart';
import 'premium_funnel_provider.dart';
import 'subscription_provider.dart';

/// Étape 3 — Payment : choix méthode + checkout.
///
/// Note : seul `url_launcher` est dispo dans le projet (pas de SDK
/// Apple Pay / Google Pay direct). On expose donc 3 "méthodes" UI mais,
/// pour Apple Pay / Google Pay, on ouvre une **fallback URL Stripe** qui
/// gère les wallets côté serveur. La méthode "Card" suit le même flux
/// (Stripe gère le formulaire de carte).
class PaymentStep extends ConsumerWidget {
  const PaymentStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final funnel = ref.watch(premiumFunnelProvider);
    final notifier = ref.read(premiumFunnelProvider.notifier);
    final methods = _availableMethods(l10n);

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
                  l10n.funnelPaymentTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.4,
                    color: PremiumTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _PlanSummary(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.funnelPaymentMethods,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: PremiumTheme.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...methods.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PaymentMethodCard(
                      method: m,
                      selected: funnel.paymentMethod == m.id,
                      onTap: () => notifier.selectPaymentMethod(m.id),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassButton(
                  label: l10n.funnelSubscribe,
                  icon: Icons.lock,
                  onPressed: () => _subscribe(context, ref, funnel.planChoice),
                ),
                const SizedBox(height: AppSpacing.md),
                _LegalFooter(),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Liste des méthodes selon plateforme (iOS masque Google Pay, etc.).
  List<_PaymentMethodSpec> _availableMethods(AppLocalizations l10n) {
    final all = <_PaymentMethodSpec>[
      _PaymentMethodSpec(
        id: PaymentMethod.applePay,
        label: l10n.funnelApplePay,
        icon: Icons.apple,
        isAvailable: !_isAndroid,
      ),
      _PaymentMethodSpec(
        id: PaymentMethod.googlePay,
        label: l10n.funnelGooglePay,
        icon: Icons.g_mobiledata,
        isAvailable: !_isIOS,
      ),
      _PaymentMethodSpec(
        id: PaymentMethod.card,
        label: l10n.funnelCard,
        icon: Icons.credit_card,
        isAvailable: true,
      ),
    ];
    final supported = all.where((m) => m.isAvailable).toList();
    if (supported.isEmpty) return [all.last];
    return supported;
  }

  bool get _isIOS {
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  bool get _isAndroid {
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  /// Déclenche le flow Stripe — toutes les méthodes ouvrent une URL Stripe
  /// qui prend en charge Apple Pay / Google Pay / Card côté serveur.
  Future<void> _subscribe(
    BuildContext context,
    WidgetRef ref,
    PlanChoice plan,
  ) async {
    // Note: `subscriptionProvider.createCheckoutSession` est codé en dur
    // sur `PREMIUM_MONTHLY`. L'API ne supporte pas encore le paramètre
    // Annual — c'est un compromis documenté. On laisse donc `plan` non
    // transmis pour l'instant (v1 du funnel).
    final url = await ref
        .read(subscriptionProvider.notifier)
        .createCheckoutSession();
    if (!context.mounted) return;
    if (url != null) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).error)),
      );
    }
  }
}

/// Spec d'une méthode de paiement (UI-only).
class _PaymentMethodSpec {
  const _PaymentMethodSpec({
    required this.id,
    required this.label,
    required this.icon,
    required this.isAvailable,
  });
  final PaymentMethod id;
  final String label;
  final IconData icon;
  final bool isAvailable;
}

/// Carte cliquable pour une méthode de paiement.
class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final _PaymentMethodSpec method;
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
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? accent
              : PremiumTheme.glass(context, elevated: true),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : PremiumTheme.border(context),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? PremiumTheme.glow(context, color: accent)
              : PremiumTheme.softShadow(context),
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              size: 24,
              color: selected ? Colors.white : PremiumTheme.textPrimary(context),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                method.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : PremiumTheme.textPrimary(context),
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? Colors.white : PremiumTheme.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Récap du plan choisi (Monthly / Annual).
class _PlanSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer(
      builder: (context, ref, _) {
        final choice = ref.watch(
          premiumFunnelProvider.select((s) => s.planChoice),
        );
        final isAnnual = choice == PlanChoice.annual;

        return GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: 20,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C896).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFF00C896),
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAnnual
                          ? l10n.funnelAnnualTitle
                          : l10n.funnelMonthlyTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: PremiumTheme.textPrimary(context),
                      ),
                    ),
                    Text(
                      isAnnual
                          ? '${l10n.funnelAnnualPrice} · ${l10n.funnelPerYear}'
                          : '${l10n.funnelMonthlyPrice} · ${l10n.funnelPerMonth}',
                      style: TextStyle(
                        fontSize: 12,
                        color: PremiumTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Footer légal (CGV + Privacy).
class _LegalFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        l10n.funnelLegalFooter,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: PremiumTheme.textTertiary(context),
        ),
      ),
    );
  }
}
