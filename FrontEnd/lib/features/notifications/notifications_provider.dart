import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';
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
  static const _pantryAlertsKey = 'notifications.pantryAlerts';
  static const _budgetAlertsKey = 'notifications.budgetAlerts';
  static const _weeklyRemindersKey = 'notifications.weeklyReminders';
  static const _promoKey = 'notifications.promotionalNotifications';

  @override
  NotificationPreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationPreferences(
      pantryAlerts: prefs.getBool(_pantryAlertsKey) ?? true,
      budgetAlerts: prefs.getBool(_budgetAlertsKey) ?? true,
      weeklyReminders: prefs.getBool(_weeklyRemindersKey) ?? true,
      promotionalNotifications: prefs.getBool(_promoKey) ?? false,
    );
  }

  Future<void> setPantryAlerts(bool value) async {
    state = state.copyWith(pantryAlerts: value);
    await ref.read(sharedPreferencesProvider).setBool(_pantryAlertsKey, value);
  }

  Future<void> setBudgetAlerts(bool value) async {
    state = state.copyWith(budgetAlerts: value);
    await ref.read(sharedPreferencesProvider).setBool(_budgetAlertsKey, value);
  }

  Future<void> setWeeklyReminders(bool value) async {
    state = state.copyWith(weeklyReminders: value);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_weeklyRemindersKey, value);
  }

  Future<void> setPromotionalNotifications(bool value) async {
    state = state.copyWith(promotionalNotifications: value);
    await ref.read(sharedPreferencesProvider).setBool(_promoKey, value);
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
