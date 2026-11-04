import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router/app_router.dart';
import '../network/api_client.dart';
import '../providers/app_session_provider.dart';
import 'notification_service.dart';

/// Shell service handling Firebase Cloud Messaging registration and routing.
///
/// This is intentionally minimal in Sprint 7.2: it requests the FCM / APNs
/// token, registers it with the PlatePilote backend (`POST /api/v1/devices`),
/// and wires up listeners for foreground / opened messages. Real triage,
/// routing, and rich payloads land in Sprint 7.3.
class PushNotificationService {
  PushNotificationService(this._messaging);

  final FirebaseMessaging _messaging;
  bool _listening = false;

  String get _currentPlatform {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => 'unknown',
    };
  }

  /// Requests notification permission and returns the FCM token, or `null`
  /// when the user denied the prompt.
  Future<String?> requestPermissionAndGetToken() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }
    return _messaging.getToken();
  }

  /// Registers the [token] with the PlatePilote backend so it can target
  /// pushes via FCM (Android) / APNs (iOS).
  Future<void> registerTokenWithBackend({
    required String token,
    required ApiClient apiClient,
  }) async {
    await apiClient.post(
      '/devices',
      data: {'deviceToken': token, 'platform': _currentPlatform},
    );
  }

  /// Returns the current FCM token, if Firebase is configured.
  Future<String?> currentToken() => _messaging.getToken();

  /// Deactivates this token on the backend after push consent is withdrawn.
  Future<void> unregisterTokenWithBackend({
    required String token,
    required ApiClient apiClient,
  }) async {
    await apiClient.post('/devices/unregister', data: {'deviceToken': token});
  }

  /// Deletes the local FCM token after backend deactivation.
  Future<void> deleteLocalToken() => _messaging.deleteToken();

  /// Subscribes once to foreground and opened-message events.
  void listenToMessages({required void Function(String route) onRoute}) {
    if (_listening) return;
    _listening = true;
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleOpened(message, onRoute),
    );
  }

  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  void _handleForeground(RemoteMessage message) {
    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if (title == null || title.isEmpty || body == null || body.isEmpty) return;

    final category = message.data['category']?.toString().toLowerCase();
    final payload = message.data['route']?.toString();
    final display = category == 'pantry' || category == 'budget'
        ? NotificationService.instance.showWarning(
            title: title,
            body: body,
            payload: payload,
          )
        : NotificationService.instance.showReminder(
            title: title,
            body: body,
            payload: payload,
          );
    unawaited(
      display.catchError((Object error) {
        debugPrint('Could not display foreground push notification: $error');
      }),
    );
  }

  void _handleOpened(
    RemoteMessage message,
    void Function(String route) onRoute,
  ) {
    final route = message.data['route'];
    if (_isSafeInternalRoute(route)) {
      onRoute(route as String);
    }
  }

  static bool _isSafeInternalRoute(Object? value) {
    if (value is! String || !value.startsWith('/') || value.startsWith('//')) {
      return false;
    }
    return !value.contains('://');
  }
}

/// Riverpod entry point for the push service. The Firebase Messaging
/// instance is the framework singleton so reads remain cheap.
final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService(FirebaseMessaging.instance);
});

/// Triggers push registration on sign-in. Register this provider once at
/// the app root (or in `appInitializationProvider`) so the listener stays
/// attached across rebuilds.
final pushSessionHookProvider = Provider<void>((ref) {
  final initialSession = ref.read(appSessionProvider);
  if (initialSession.isAuthenticated) {
    Future.microtask(() {
      if (initialSession.hasAcceptedPush) {
        _registerPush(ref);
      } else {
        _unregisterPush(ref);
      }
    });
  }

  ref.listen<AppSessionState>(appSessionProvider, (prev, next) async {
    final pushConsentRevoked =
        next.isAuthenticated &&
        prev?.hasAcceptedPush == true &&
        !next.hasAcceptedPush;
    if (pushConsentRevoked) {
      await _unregisterPush(ref);
      return;
    }

    final hasNewPushConsent =
        next.hasAcceptedPush && prev?.hasAcceptedPush != true;
    final hasNewAuthenticatedSession =
        next.isAuthenticated && prev?.isAuthenticated != true;
    if (next.isAuthenticated &&
        next.hasAcceptedPush &&
        (hasNewAuthenticatedSession || hasNewPushConsent)) {
      await _registerPush(ref);
    }
  });
});

Future<void> _registerPush(Ref ref) async {
  try {
    final push = ref.read(pushNotificationServiceProvider);
    final apiClient = ref.read(apiClientProvider);
    final router = ref.read(appRouterProvider);
    void navigateToSafeRoute(String route) => router.go(route);
    push.listenToMessages(onRoute: navigateToSafeRoute);
    final initialMessage = await push.getInitialMessage();
    if (initialMessage != null) {
      final route = initialMessage.data['route'];
      if (route is String &&
          route.startsWith('/') &&
          !route.startsWith('//') &&
          !route.contains('://')) {
        navigateToSafeRoute(route);
      }
    }
    final token = await push.requestPermissionAndGetToken();
    if (token != null) {
      await push.registerTokenWithBackend(token: token, apiClient: apiClient);
    }
  } catch (e, st) {
    debugPrint('Push registration failed (non-blocking): $e\n$st');
  }
}

Future<void> _unregisterPush(Ref ref) async {
  try {
    final push = ref.read(pushNotificationServiceProvider);
    final apiClient = ref.read(apiClientProvider);
    final token = await push.currentToken();
    if (token != null) {
      await push.unregisterTokenWithBackend(token: token, apiClient: apiClient);
    }
    await push.deleteLocalToken();
  } catch (e, st) {
    debugPrint('Push unregistration failed (non-blocking): $e\n$st');
  }
}
