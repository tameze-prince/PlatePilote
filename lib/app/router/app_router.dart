import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_session_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/budget/budget_management_screen.dart';
import '../../features/grocery/forms/add_grocery_item_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/grocery/grocery_list_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/localization/language_settings_screen.dart';
import '../../features/meal_plan/weekly_plan_screen.dart';
import '../../features/notifications/notification_preferences_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_flow.dart';
import '../../features/pantry/forms/add_pantry_item_screen.dart';
import '../../features/pantry/pantry_screen.dart';
import '../../features/premium/premium_upgrade_screen.dart';
import '../../features/preferences/edit_preferences_screen.dart';
import '../../features/quick_meal/quick_meal_screen.dart';
import '../../features/recipe/recipe_details_screen.dart';
import '../../features/recipes/forms/add_recipe_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = ref.read(appSessionProvider);
      final location = state.matchedLocation;
      final publicRoutes = {'/splash', '/onboarding', '/login', '/signup'};

      if (publicRoutes.contains(location)) {
        return null;
      }

      if (!session.hasSeenOnboarding) {
        return '/onboarding';
      }

      if (!session.isAuthenticated) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingFlow(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: AppRoute.signup.name,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/quick-meal',
        name: AppRoute.quickMeal.name,
        builder: (context, state) => const QuickMealScreen(),
      ),
      GoRoute(
        path: '/recipe/:id',
        name: AppRoute.recipeDetails.name,
        builder: (context, state) =>
            RecipeDetailsScreen(recipeId: state.pathParameters['id'] ?? '0'),
      ),
      GoRoute(
        path: '/premium',
        name: AppRoute.premium.name,
        builder: (context, state) => const PremiumUpgradeScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: AppRoute.notifications.name,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/notification-preferences',
        name: AppRoute.notificationPreferences.name,
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
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
        path: '/budget',
        name: AppRoute.budget.name,
        builder: (context, state) => const BudgetManagementScreen(),
      ),
      GoRoute(
        path: '/pantry/add',
        name: AppRoute.addPantryItem.name,
        builder: (context, state) => const AddPantryItemScreen(),
      ),
      GoRoute(
        path: '/grocery/add',
        name: AppRoute.addGroceryItem.name,
        builder: (context, state) => const AddGroceryItemScreen(),
      ),
      GoRoute(
        path: '/recipes/add',
        name: AppRoute.addRecipe.name,
        builder: (context, state) => const AddRecipeScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PlatePilotShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home.name,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plan',
                name: AppRoute.plan.name,
                builder: (context, state) => const WeeklyPlanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/grocery',
                name: AppRoute.grocery.name,
                builder: (context, state) => const GroceryListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pantry',
                name: AppRoute.pantry.name,
                builder: (context, state) => const PantryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: AppRoute.settings.name,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

enum AppRoute {
  splash,
  onboarding,
  login,
  signup,
  home,
  plan,
  grocery,
  pantry,
  settings,
  quickMeal,
  recipeDetails,
  premium,
  notifications,
  notificationPreferences,
  language,
  preferences,
  budget,
  addPantryItem,
  addGroceryItem,
  addRecipe,
}

class PlatePilotShell extends StatelessWidget {
  const PlatePilotShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Grocery',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Pantry',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
