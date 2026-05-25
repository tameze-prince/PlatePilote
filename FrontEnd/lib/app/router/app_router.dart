import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_session_provider.dart';
import '../../core/widgets/floating_components.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/email_verification_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/budget/budget_management_screen.dart';
import '../../features/budget/budget_analytics_screen.dart';
import '../../features/budget/savings_tracker_screen.dart';
import '../../features/grocery/forms/add_grocery_item_screen.dart';
import '../../features/grocery/forms/edit_grocery_item_screen.dart';
import '../../features/grocery/grocery_list_screen.dart';
import '../../features/grocery/cost_breakdown_screen.dart';
import '../../features/grocery/purchase_history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/localization/language_settings_screen.dart';
import '../../features/meal_details/meal_details_screen.dart';
import '../../features/meal_plan/weekly_plan_screen.dart';
import '../../features/meal_plan/meal_swap_screen.dart';
import '../../features/meal_plan/plan_acceptance_screen.dart';
import '../../features/meal_plan/meal_plan_history_screen.dart';
import '../../shared/models/meal_plan.dart';
import '../../features/notifications/notification_preferences_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_flow.dart';
import '../../features/pantry/forms/add_pantry_item_screen.dart';
import '../../features/pantry/forms/edit_pantry_item_screen.dart';
import '../../features/pantry/pantry_screen.dart';
import '../../features/pantry/expiration_dashboard_screen.dart';
import '../../features/premium/premium_upgrade_screen.dart';
import '../../features/premium/payment_method_screen.dart';
import '../../features/premium/subscription_management_screen.dart';
import '../../features/preferences/edit_preferences_screen.dart';
import '../../features/preferences/food_preferences_screen.dart';
import '../../features/quick_meal/quick_meal_screen.dart';
import '../../features/recipe/recipe_details_screen.dart';
import '../../features/recipes/forms/add_recipe_screen.dart';
import '../../features/recipes/favorites_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/support/offline_screen.dart';
import '../../shared/models/demo_data.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = ref.read(appSessionProvider);
      final location = state.matchedLocation;
      final isPublicRoute = location == '/splash' || 
                           location == '/onboarding' || 
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
        path: '/verify-email',
        name: AppRoute.verifyEmail.name,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return EmailVerificationScreen(token: token);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
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
        path: '/meal/:id',
        name: AppRoute.mealDetails.name,
        builder: (context, state) =>
            MealDetailsScreen(mealId: state.pathParameters['id'] ?? '0'),
      ),
      GoRoute(
        path: '/meal-swap/:dayIndex/:mealType',
        name: AppRoute.mealSwap.name,
        builder: (context, state) {
          final dayIndex = int.parse(state.pathParameters['dayIndex'] ?? '0');
          final mealType = state.pathParameters['mealType'] ?? 'Dinner';
          final extra = state.extra;
          final Meal currentMeal;
          final MealPlanEntry? currentEntry;
          if (extra is Map<String, dynamic>) {
            currentMeal = extra['meal'] as Meal? ??
                const Meal(
                  day: '', type: 'Dinner', title: 'Unknown',
                  minutes: 0, kcal: 0, icon: Icons.restaurant,
                  tint: Color(0xFF22C55E),
                );
            currentEntry = extra['entry'] as MealPlanEntry?;
          } else {
            currentMeal = extra as Meal? ??
                const Meal(
                  day: '', type: 'Dinner', title: 'Unknown',
                  minutes: 0, kcal: 0, icon: Icons.restaurant,
                  tint: Color(0xFF22C55E),
                );
            currentEntry = null;
          }
          return MealSwapScreen(
            currentMeal: currentMeal,
            dayIndex: dayIndex,
            mealType: mealType,
            currentEntry: currentEntry,
          );
        },
      ),
      GoRoute(
        path: '/plan-acceptance',
        name: AppRoute.planAcceptance.name,
        builder: (context, state) {
          final plan = state.extra as MealPlan? ??
              MealPlan(id: '', name: '', entries: []);
          return PlanAcceptanceScreen(plan: plan);
        },
      ),
      GoRoute(
        path: '/premium',
        name: AppRoute.premium.name,
        builder: (context, state) => const PremiumUpgradeScreen(),
      ),
      GoRoute(
        path: '/subscription',
        name: AppRoute.subscription.name,
        builder: (context, state) => const SubscriptionManagementScreen(),
      ),
      GoRoute(
        path: '/payment-method',
        name: AppRoute.paymentMethod.name,
        builder: (context, state) => const PaymentMethodScreen(),
      ),
      GoRoute(
        path: '/search',
        name: AppRoute.search.name,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/favorites',
        name: AppRoute.favorites.name,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/offline',
        name: AppRoute.offline.name,
        builder: (context, state) => const OfflineScreen(),
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
        path: '/food-preferences',
        name: AppRoute.foodPreferences.name,
        builder: (context, state) => const FoodPreferencesScreen(),
      ),
      GoRoute(
        path: '/budget',
        name: AppRoute.budget.name,
        builder: (context, state) => const BudgetManagementScreen(),
      ),
      GoRoute(
        path: '/budget-analytics',
        name: AppRoute.budgetAnalytics.name,
        builder: (context, state) => const BudgetAnalyticsScreen(),
      ),
      GoRoute(
        path: '/savings-tracker',
        name: AppRoute.savingsTracker.name,
        builder: (context, state) => const SavingsTrackerScreen(),
      ),
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
      GoRoute(
        path: '/recipes/add',
        name: AppRoute.addRecipe.name,
        builder: (context, state) => const AddRecipeScreen(),
      ),
      GoRoute(
        path: '/plan-history',
        name: AppRoute.planHistory.name,
        builder: (context, state) => const MealPlanHistoryScreen(),
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
                path: '/profile',
                name: AppRoute.profile.name,
                builder: (context, state) => const ProfileScreen(),
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
  subscription,
  paymentMethod,
  search,
  favorites,
  offline,
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
}

class PlatePilotShell extends StatelessWidget {
  const PlatePilotShell({required this.navigationShell, super.key});

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
