import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/meal_details/meal_details_screen.dart';
import '../../../features/meal_plan/meal_plan_history_screen.dart';
import '../../../features/meal_plan/meal_swap_screen.dart';
import '../../../features/meal_plan/plan_acceptance_screen.dart';
import '../../../features/meal_plan/weekly_plan_screen.dart';
import '../../../shared/models/demo_data.dart' show Meal;
import '../../../shared/models/meal_plan.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> planRoutes() {
  return <RouteBase>[
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
        final dayIndex =
            int.parse(state.pathParameters['dayIndex'] ?? '0');
        final mealType = state.pathParameters['mealType'] ?? 'Dinner';
        final extra = state.extra;
        final Meal currentMeal;
        final MealPlanEntry? currentEntry;
        if (extra is Map<String, dynamic>) {
          currentMeal = extra['meal'] as Meal? ??
              const Meal(
                day: '',
                type: 'Dinner',
                title: 'Unknown',
                minutes: 0,
                kcal: 0,
                icon: Icons.restaurant,
                tint: Color(0xFF22C55E),
              );
          currentEntry = extra['entry'] as MealPlanEntry?;
        } else {
          currentMeal = extra as Meal? ??
              const Meal(
                day: '',
                type: 'Dinner',
                title: 'Unknown',
                minutes: 0,
                kcal: 0,
                icon: Icons.restaurant,
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
      path: '/plan-history',
      name: AppRoute.planHistory.name,
      builder: (context, state) => const MealPlanHistoryScreen(),
    ),
  ];
}

/// Branche du StatefulShellRoute pour le plan hebdomadaire.
StatefulShellBranch planShellBranch() {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: '/plan',
        name: AppRoute.plan.name,
        builder: (context, state) => const WeeklyPlanScreen(),
      ),
    ],
  );
}
