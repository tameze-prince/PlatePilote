import 'package:go_router/go_router.dart';

import '../../../features/splash/splash_screen.dart';
import '../../../features/support/offline_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> supportRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/splash',
      name: AppRoute.splash.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/offline',
      name: AppRoute.offline.name,
      builder: (context, state) => const OfflineScreen(),
    ),
  ];
}
