import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/notification.dart' as ntf;
import 'notification_repository.dart';

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

class NotificationsNotifier extends Notifier<AsyncValue<List<ntf.AppNotification>>> {
  @override
  AsyncValue<List<ntf.AppNotification>> build() {
    Future.microtask(() => _loadNotifications());
    return const AsyncValue.loading();
  }

  Future<void> _loadNotifications() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final page = await repo.getNotifications(size: 50);
      state = AsyncValue.data(page.content);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead();
    state = state.whenData(
      (notifications) => notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  Future<void> toggleRead(String id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
    state = state.whenData(
      (notifications) => notifications.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(notificationRepositoryProvider).deleteNotification(id);
    state = state.whenData(
      (notifications) => notifications.where((n) => n.id != id).toList(),
    );
  }

  Future<void> refresh() => _loadNotifications();
}

class NotificationPreferencesNotifier
    extends Notifier<NotificationPreferences> {
  @override
  NotificationPreferences build() {
    Future.microtask(() => _loadPreferences());
    return const NotificationPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final response = await ref.read(apiClientProvider).get('/notification-preferences');
      final data = response.data['data'] as Map<String, dynamic>;
      state = NotificationPreferences(
        pantryAlerts: data['pantryReminders'] as bool? ?? true,
        budgetAlerts: data['groceryReminders'] as bool? ?? true,
        weeklyReminders: data['mealPlanReminders'] as bool? ?? true,
        promotionalNotifications: data['recipeRecommendations'] as bool? ?? false,
      );
    } catch (_) {}
  }

  Future<void> setPantryAlerts(bool value) async {
    state = state.copyWith(pantryAlerts: value);
    await _syncPreferences();
  }

  Future<void> setBudgetAlerts(bool value) async {
    state = state.copyWith(budgetAlerts: value);
    await _syncPreferences();
  }

  Future<void> setWeeklyReminders(bool value) async {
    state = state.copyWith(weeklyReminders: value);
    await _syncPreferences();
  }

  Future<void> setPromotionalNotifications(bool value) async {
    state = state.copyWith(promotionalNotifications: value);
    await _syncPreferences();
  }

  Future<void> _syncPreferences() async {
    try {
      await ref.read(apiClientProvider).put('/notification-preferences', data: {
        'pantryReminders': state.pantryAlerts,
        'groceryReminders': state.budgetAlerts,
        'mealPlanReminders': state.weeklyReminders,
        'recipeRecommendations': state.promotionalNotifications,
      });
    } catch (_) {}
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, AsyncValue<List<ntf.AppNotification>>>(
      NotificationsNotifier.new,
    );

final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
      NotificationPreferencesNotifier.new,
    );
