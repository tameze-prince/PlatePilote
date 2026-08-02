import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../shared/models/mvp_entities.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

/// Service de notifications locales pour les rappels de repas,
/// alertes de garde-manger et avertissements de budget.
class NotificationService {
  NotificationService._();

  /// Instance singleton du service de notifications.
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _reminderChannel = AndroidNotificationChannel(
    'platepilot_reminders',
    'Meal and grocery reminders',
    description: 'Scheduled reminders for meal plans and grocery tasks.',
    importance: Importance.high,
  );

  static const _warningChannel = AndroidNotificationChannel(
    'platepilot_warnings',
    'Pantry and budget warnings',
    description: 'Important pantry expiration and budget warning alerts.',
    importance: Importance.max,
  );

  bool _initialized = false;

  /// Initialise le plugin de notifications et crée les canaux Android.
  Future<void> initialize() async {
    if (kIsWeb || _initialized) {
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_reminderChannel);
    await androidPlugin?.createNotificationChannel(_warningChannel);

    _initialized = true;
  }

  /// Demande les permissions de notification sur Android, iOS et macOS.
  /// Retourne `false` sur le web.
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return false;
    }

    await initialize();

    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final macGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return androidGranted ?? iosGranted ?? macGranted ?? false;
  }

  /// Affiche une notification de rappel (repas, courses).
  Future<void> showReminder({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _show(
      id: _idFromPayload(payload ?? '$title$body'),
      title: title,
      body: body,
      payload: payload,
      category: NotificationCategory.mealPlan,
    );
  }

  /// Affiche une notification d'avertissement (garde-manger, budget).
  Future<void> showWarning({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _show(
      id: _idFromPayload(payload ?? '$title$body'),
      title: title,
      body: body,
      payload: payload,
      category: NotificationCategory.budget,
    );
  }

  /// Planifie un rappel après un délai [delay].
  /// Ignoré sur le web.
  Future<void> scheduleReminder({
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    await _plugin.zonedSchedule(
      id: _idFromPayload(payload ?? '$title$body$delay'),
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: _details(NotificationCategory.mealPlan),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Annule toutes les notifications planifiées et affichées.
  Future<void> cancelAll() async {
    if (kIsWeb) {
      return;
    }
    await _plugin.cancelAll();
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    required NotificationCategory category,
    String? payload,
  }) async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(category),
      payload: payload,
    );
  }

  NotificationDetails _details(NotificationCategory category) {
    final warning =
        category == NotificationCategory.pantry ||
        category == NotificationCategory.budget;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        warning ? _warningChannel.id : _reminderChannel.id,
        warning ? _warningChannel.name : _reminderChannel.name,
        channelDescription: warning
            ? _warningChannel.description
            : _reminderChannel.description,
        importance: warning ? Importance.max : Importance.high,
        priority: warning ? Priority.max : Priority.high,
        category: AndroidNotificationCategory.reminder,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: warning
            ? InterruptionLevel.timeSensitive
            : InterruptionLevel.active,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  int _idFromPayload(String value) {
    return value.hashCode & 0x7fffffff;
  }
}