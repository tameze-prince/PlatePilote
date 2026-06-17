import 'package:go_router/go_router.dart';

import '../../../features/pantry/expiration_dashboard_screen.dart';
import '../../../features/pantry/forms/add_pantry_item_screen.dart';
import '../../../features/pantry/forms/edit_pantry_item_screen.dart';
import '../../../features/pantry/pantry_screen.dart';
import '../../../shared/models/demo_data.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> pantryRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/pantry/add',
      name: AppRoute.addPantryItem.name,
      builder: (context, state) => const AddPantryItemScreen(),
    ),
    GoRoute(
      path: '/pantry/edit/:id',
      name: AppRoute.editPantryItem.name,
      builder: (context, state) {
        final item = state.extra as PantryItem?;
        return EditPantryItemScreen(item: item);
      },
    ),
    GoRoute(
      path: '/pantry/expirations',
      name: AppRoute.pantryExpirations.name,
      builder: (context, state) => const PantryExpirationScreen(),
    ),
  ];
}

/// Branche du StatefulShellRoute pour le garde-manger.
StatefulShellBranch pantryShellBranch() {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: '/pantry',
        name: AppRoute.pantry.name,
        builder: (context, state) => const PantryScreen(),
      ),
    ],
  );
}
