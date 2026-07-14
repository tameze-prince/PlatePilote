import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_session_provider.dart';
import '../../core/widgets/floating_components.dart';
import 'routes/_registry.dart';

export 'routes/_registry.dart' show AppRoutes;

/// Provider du routeur GoRouter avec redirect pour l'authentification.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = ref.read(appSessionProvider);
      final location = state.matchedLocation;
      final isPublicRoute = location == '/splash' ||
          location == '/onboarding' ||
          location == '/consent' ||
          location == '/signup' ||
          location == '/login' ||
          location.startsWith('/verify-email') ||
          location.startsWith('/forgot-password');

      if (isPublicRoute) {
        if (location == '/onboarding' && session.hasSeenOnboarding) {
          final after = state.uri.queryParameters['after'];
          if (after == 'signup') return null;
          return session.isAuthenticated ? '/home' : '/login';
        }
        if (location == '/consent') {
          if (!session.hasSeenOnboarding) return '/onboarding';
          if (!session.isAuthenticated) return '/login';
          if (session.hasAcceptedBetaAnalytics) return '/home';
        }
        return null;
      }

      if (!session.hasSeenOnboarding) {
        return '/onboarding';
      }

      if (!session.isAuthenticated) {
        return '/login';
      }

      if (!session.hasAcceptedBetaAnalytics) {
        return '/consent';
      }

      return null;
    },
    routes: AppRoutes.all,
  );
});

/// Énumération des routes de l'application.
///
/// Conservée dans `app_router.dart` car elle est référencée à travers
/// l'ensemble des fichiers `routes/*_routes.dart` et par le code appelant.
enum AppRoute {
  splash,
  onboarding,
  login,
  signup,
  verifyEmail,
  forgotPassword,
  home,
  plan,
  grocery,
  pantry,
  settings,
  profile,
  foodPreferences,
  quickMeal,
  recipeDetails,
  mealDetails,
  mealSwap,
  planAcceptance,
  premium,
  premiumFunnel,
  subscription,
  paymentMethod,
  search,
  favorites,
  offline,
  consent,
  notifications,
  notificationPreferences,
  language,
  preferences,
  budget,
  budgetAnalytics,
  savingsTracker,
  addPantryItem,
  editPantryItem,
  pantryExpirations,
  addGroceryItem,
  editGroceryItem,
  groceryBreakdown,
  groceryHistory,
  addRecipe,
  planHistory,
  commandPalette,
}

/// Shell avec barre de navigation pour les routes principales.
///
/// Utilisé par le [StatefulShellRoute.indexedStack] défini dans
/// `routes/home_routes.dart` qui agrège les branches des features
/// home, plan, grocery, pantry et profile.
class PlatePilotShell extends StatelessWidget {
  const PlatePilotShell({required this.navigationShell, super.key});

  /// Shell de navigation stateful.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: FloatingNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          FloatingNavDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
          FloatingNavDestination(
            icon: Icons.calendar_month_outlined,
            selectedIcon: Icons.calendar_month,
            label: 'Plan',
          ),
          FloatingNavDestination(
            icon: Icons.shopping_cart_outlined,
            selectedIcon: Icons.shopping_cart,
            label: 'Grocery',
          ),
          FloatingNavDestination(
            icon: Icons.kitchen_outlined,
            selectedIcon: Icons.kitchen,
            label: 'Pantry',
          ),
          FloatingNavDestination(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
