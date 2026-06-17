import 'package:go_router/go_router.dart';

import '../../../features/profile/profile_screen.dart';
import '../../../features/quick_meal/quick_meal_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> profileRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/quick-meal',
      name: AppRoute.quickMeal.name,
      builder: (context, state) => const QuickMealScreen(),
    ),
  ];
}

/// Branche du StatefulShellRoute pour le profil utilisateur.
StatefulShellBranch profileShellBranch() {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: '/profile',
        name: AppRoute.profile.name,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
