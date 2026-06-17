import 'package:go_router/go_router.dart';

import '../../../features/notifications/notification_preferences_screen.dart';
import '../../../features/notifications/notifications_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> notificationsRoutes() {
  return <RouteBase>[
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
  ];
}
