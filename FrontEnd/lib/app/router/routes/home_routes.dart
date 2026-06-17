import 'package:go_router/go_router.dart';

import '../../../features/home/home_screen.dart';
import '../app_router.dart' show AppRoute, PlatePilotShell;
import 'plan_routes.dart' show planShellBranch;
import 'grocery_routes.dart' show groceryShellBranch;
import 'pantry_routes.dart' show pantryShellBranch;
import 'profile_routes.dart' show profileShellBranch;

/// Première branche du StatefulShellRoute : l'écran d'accueil.
StatefulShellBranch homeShellBranch() {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}

List<RouteBase> homeRoutes() {
  return <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PlatePilotShell(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        homeShellBranch(),
        planShellBranch(),
        groceryShellBranch(),
        pantryShellBranch(),
        profileShellBranch(),
      ],
    ),
  ];
}
