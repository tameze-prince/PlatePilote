import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../providers/app_session_provider.dart';

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
      data: {
        'deviceToken': token,
        'platform': Platform.operatingSystem,
      },
    );
  }

  /// Returns the current FCM token, if Firebase is configured.
  Future<String?> currentToken() => _messaging.getToken();

  /// Deactivates this token on the backend after push consent is withdrawn.
  Future<void> unregisterTokenWithBackend({
    required String token,
    required ApiClient apiClient,
  }) async {
    await apiClient.post(
      '/devices/unregister',
      data: {'deviceToken': token},
    );
  }

  /// Deletes the local FCM token after backend deactivation.
  Future<void> deleteLocalToken() => _messaging.deleteToken();

  /// Subscribes to foreground and tap-opened push events. Intended to be
  /// called once after the user authenticates and the FCM token has been
  /// resolved.
  void listenToMessages() {
    if (_listening) return;
    _listening = true;
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpened);
  }

  void _handleForeground(RemoteMessage message) {
    // Sprint 7.2 placeholder: log + future hand-off to flutter_local_notifications
    // so the banner shows even when the app is in the foreground.
    // Full UI is delivered in Sprint 7.3.
    debugPrint(
      'Push foreground: ${message.notification?.title} / ${message.data}',
    );
  }

  void _handleOpened(RemoteMessage message) {
    final route = message.data['route'];
    if (route is String && route.isNotEmpty) {
      debugPrint('Push opened -> route=$route');
      // Sprint 7.3: hand off to GoRouter.
    }
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
  ref.listen<AppSessionState>(appSessionProvider, (prev, next) async {
    final pushConsentRevoked = next.isAuthenticated &&
        prev?.hasAcceptedPush == true &&
        !next.hasAcceptedPush;
    if (pushConsentRevoked) {
      await _unregisterPush(ref);
      return;
    }

    final hasNewPushConsent = next.hasAcceptedPush && prev?.hasAcceptedPush != true;
    final hasNewAuthenticatedSession = next.isAuthenticated && prev?.isAuthenticated != true;
    if (next.isAuthenticated && next.hasAcceptedPush &&
        (hasNewAuthenticatedSession || hasNewPushConsent)) {
      await _registerPush(ref);
    }
  });
});

Future<void> _registerPush(Ref ref) async {
  try {
    final push = ref.read(pushNotificationServiceProvider);
    final apiClient = ref.read(apiClientProvider);
    push.listenToMessages();
    final token = await push.requestPermissionAndGetToken();
    if (token != null) {
      await push.registerTokenWithBackend(
        token: token,
        apiClient: apiClient,
      );
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
