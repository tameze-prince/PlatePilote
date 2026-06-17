import 'package:go_router/go_router.dart';

import 'auth_routes.dart';
import 'budget_routes.dart';
import 'grocery_routes.dart';
import 'home_routes.dart';
import 'notifications_routes.dart';
import 'onboarding_routes.dart';
import 'pantry_routes.dart';
import 'plan_routes.dart';
import 'preferences_routes.dart';
import 'premium_routes.dart';
import 'profile_routes.dart';
import 'search_routes.dart';
import 'support_routes.dart';

/// Barrel central des routes de l'application.
///
/// Agrège toutes les listes `List<RouteBase>` exposées par chaque fichier
/// de routes par feature et les concatène via [AppRoutes.all].
class AppRoutes {
  const AppRoutes._();

  static final List<RouteBase> all = <RouteBase>[
    ...authRoutes(),
    ...onboardingRoutes(),
    ...supportRoutes(),
    ...homeRoutes(),
    ...planRoutes(),
    ...pantryRoutes(),
    ...groceryRoutes(),
    ...budgetRoutes(),
    ...profileRoutes(),
    ...preferencesRoutes(),
    ...premiumRoutes(),
    ...searchRoutes(),
    ...notificationsRoutes(),
  ];
}
