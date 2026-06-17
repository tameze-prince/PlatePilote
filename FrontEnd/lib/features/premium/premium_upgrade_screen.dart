import 'premium_funnel_screen.dart';

/// Écran de promotion et d'achat de l'abonnement Premium.
///
/// **Refacto Sprint 2** : cette classe est désormais un alias rétro-compatible
/// vers [PremiumFunnelScreen] qui héberge le funnel 3-étapes
/// (Explain → PickPlan → Payment). Les anciens call-sites `/premium-upgrade`
/// continuent de fonctionner sans modification.
///
/// Migration active :
/// - `/premium-upgrade` → ce widget (compat)
/// - `/premium-funnel` → [PremiumFunnelScreen] (route canonique post-refacto)
/// - `/premium` → ce widget (compat, voir `app_router.dart` → `AppRoute.premium`)
class PremiumUpgradeScreen extends PremiumFunnelScreen {
  const PremiumUpgradeScreen({super.key});
}
