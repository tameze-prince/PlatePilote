import 'package:go_router/go_router.dart';

import '../../../features/grocery/cost_breakdown_screen.dart';
import '../../../features/grocery/forms/add_grocery_item_screen.dart';
import '../../../features/grocery/forms/edit_grocery_item_screen.dart';
import '../../../features/grocery/grocery_list_screen.dart';
import '../../../features/grocery/purchase_history_screen.dart';
import '../../../shared/models/demo_data.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> groceryRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/grocery/add',
      name: AppRoute.addGroceryItem.name,
      builder: (context, state) => const AddGroceryItemScreen(),
    ),
    GoRoute(
      path: '/grocery/edit/:id',
      name: AppRoute.editGroceryItem.name,
      builder: (context, state) {
        final item = state.extra as GroceryItem?;
        return EditGroceryItemScreen(item: item);
      },
    ),
    GoRoute(
      path: '/grocery/breakdown',
      name: AppRoute.groceryBreakdown.name,
      builder: (context, state) => const GroceryCostBreakdownScreen(),
    ),
    GoRoute(
      path: '/grocery/history',
      name: AppRoute.groceryHistory.name,
      builder: (context, state) => const PurchaseHistoryScreen(),
    ),
  ];
}

/// Branche du StatefulShellRoute pour la liste de courses.
StatefulShellBranch groceryShellBranch() {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: '/grocery',
        name: AppRoute.grocery.name,
        builder: (context, state) => const GroceryListScreen(),
      ),
    ],
  );
}
