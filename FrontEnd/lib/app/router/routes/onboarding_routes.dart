import 'package:go_router/go_router.dart';

import '../../../features/onboarding/onboarding_single_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> onboardingRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/onboarding',
      name: AppRoute.onboarding.name,
      builder: (context, state) => const OnboardingSingleScreen(),
    ),
  ];
}
