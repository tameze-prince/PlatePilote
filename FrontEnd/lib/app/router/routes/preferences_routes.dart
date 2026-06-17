import 'package:go_router/go_router.dart';

import '../../../features/preferences/edit_preferences_screen.dart';
import '../../../features/preferences/food_preferences_screen.dart';
import '../../../features/settings/language_settings_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> preferencesRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/language',
      name: AppRoute.language.name,
      builder: (context, state) => const LanguageSettingsScreen(),
    ),
    GoRoute(
      path: '/preferences',
      name: AppRoute.preferences.name,
      builder: (context, state) => const EditPreferencesScreen(),
    ),
    GoRoute(
      path: '/food-preferences',
      name: AppRoute.foodPreferences.name,
      builder: (context, state) => const FoodPreferencesScreen(),
    ),
  ];
}
