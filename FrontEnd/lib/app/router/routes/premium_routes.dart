import 'package:go_router/go_router.dart';

import '../../../features/premium/payment_method_screen.dart';
import '../../../features/premium/premium_funnel_screen.dart';
import '../../../features/premium/premium_upgrade_screen.dart';
import '../../../features/premium/subscription_management_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> premiumRoutes() {
  return <RouteBase>[
    // Route canonique Sprint 2 : funnel 3-étapes Explain → PickPlan → Payment.
    GoRoute(
      path: '/premium-funnel',
      name: AppRoute.premiumFunnel.name,
      builder: (context, state) => const PremiumFunnelScreen(),
    ),

    // Alias rétro-compatible — l'ancien `PremiumUpgradeScreen` est désormais
    // un sous-type de `PremiumFunnelScreen` qui pointe vers le même funnel.
    GoRoute(
      path: '/premium-upgrade',
      builder: (context, state) => const PremiumUpgradeScreen(),
    ),

    // Conserve la route historique `/premium` pointant vers le funnel
    // (les anciens deep-links restent fonctionnels).
    GoRoute(
      path: '/premium',
      name: AppRoute.premium.name,
      builder: (context, state) => const PremiumUpgradeScreen(),
    ),

    // Routes non-migrées du feature premium (intactes).
    GoRoute(
      path: '/subscription',
      name: AppRoute.subscription.name,
      builder: (context, state) => const SubscriptionManagementScreen(),
    ),
    GoRoute(
      path: '/payment-method',
      name: AppRoute.paymentMethod.name,
      builder: (context, state) => const PaymentMethodScreen(),
    ),
  ];
}
