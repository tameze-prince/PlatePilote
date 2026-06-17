import 'package:go_router/go_router.dart';

import '../../../features/premium/payment_method_screen.dart';
import '../../../features/premium/premium_upgrade_screen.dart';
import '../../../features/premium/subscription_management_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> premiumRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/premium',
      name: AppRoute.premium.name,
      builder: (context, state) => const PremiumUpgradeScreen(),
    ),
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
