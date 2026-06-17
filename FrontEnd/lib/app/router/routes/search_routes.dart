import 'package:go_router/go_router.dart';

import '../../../features/recipes/forms/add_recipe_screen.dart';
import '../../../features/recipes/favorites_screen.dart';
import '../../../features/search/command_palette/command_palette_screen.dart';
import '../../../features/search/search_screen.dart';
import '../../../features/recipe/recipe_details_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> searchRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/search',
      name: AppRoute.search.name,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/command-palette',
      name: AppRoute.commandPalette.name,
      builder: (context, state) => const CommandPaletteScreen(),
    ),
    GoRoute(
      path: '/favorites',
      name: AppRoute.favorites.name,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/recipes/add',
      name: AppRoute.addRecipe.name,
      builder: (context, state) => const AddRecipeScreen(),
    ),
    GoRoute(
      path: '/recipe/:id',
      name: AppRoute.recipeDetails.name,
      builder: (context, state) =>
          RecipeDetailsScreen(recipeId: state.pathParameters['id'] ?? '0'),
    ),
  ];
}
