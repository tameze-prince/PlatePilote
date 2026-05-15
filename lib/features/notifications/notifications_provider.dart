import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/mvp_entities.dart';

class NotificationPreferences {
  const NotificationPreferences({
    this.pantryAlerts = true,
    this.budgetAlerts = true,
    this.weeklyReminders = true,
    this.promotionalNotifications = false,
  });

  final bool pantryAlerts;
  final bool budgetAlerts;
  final bool weeklyReminders;
  final bool promotionalNotifications;

  NotificationPreferences copyWith({
    bool? pantryAlerts,
    bool? budgetAlerts,
    bool? weeklyReminders,
    bool? promotionalNotifications,
  }) {
    return NotificationPreferences(
      pantryAlerts: pantryAlerts ?? this.pantryAlerts,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      weeklyReminders: weeklyReminders ?? this.weeklyReminders,
      promotionalNotifications:
          promotionalNotifications ?? this.promotionalNotifications,
    );
  }
}

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'milk',
        title: 'Pantry alert',
        message: 'Your milk expires tomorrow.',
        category: NotificationCategory.pantry,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'budget-80',
        title: 'Budget alert',
        message: 'You have used 80% of your weekly budget.',
        category: NotificationCategory.budget,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      AppNotification(
        id: 'plan-ready',
        title: 'Meal plan ready',
        message: 'Your new weekly meal plan is ready.',
        category: NotificationCategory.mealPlan,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'grocery-left',
        title: 'Grocery reminder',
        message: 'Don’t forget to buy 5 remaining items.',
        category: NotificationCategory.grocery,
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
      ),
      AppNotification(
        id: 'premium',
        title: 'Premium',
        message: 'Unlock advanced pantry automation.',
        category: NotificationCategory.premium,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }

  void markAllRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];
  }

  void toggleRead(String id) {
    state = [
      for (final notification in state)
        notification.id == id
            ? notification.copyWith(isRead: !notification.isRead)
            : notification,
    ];
  }

  void delete(String id) {
    state = state.where((notification) => notification.id != id).toList();
  }
}

class NotificationPreferencesNotifier
    extends Notifier<NotificationPreferences> {
  @override
  NotificationPreferences build() => const NotificationPreferences();

  void setPantryAlerts(bool value) {
    state = state.copyWith(pantryAlerts: value);
  }

  void setBudgetAlerts(bool value) {
    state = state.copyWith(budgetAlerts: value);
  }

  void setWeeklyReminders(bool value) {
    state = state.copyWith(weeklyReminders: value);
  }

  void setPromotionalNotifications(bool value) {
    state = state.copyWith(promotionalNotifications: value);
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
      NotificationPreferencesNotifier.new,
    );
