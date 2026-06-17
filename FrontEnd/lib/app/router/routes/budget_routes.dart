import 'package:go_router/go_router.dart';

import '../../../features/budget/budget_analytics_screen.dart';
import '../../../features/budget/budget_management_screen.dart';
import '../../../features/budget/savings_tracker_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> budgetRoutes() {
  return <RouteBase>[
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
  ];
}
