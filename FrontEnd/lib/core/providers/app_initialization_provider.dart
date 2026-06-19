import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/push_notification_service.dart';

/// Provider qui initialise les services au démarrage de l'application
/// (notifications locales, etc.). À attendre dans le splash screen.
final appInitializationProvider = FutureProvider<void>((ref) async {
  // Local notifications are initialized inside `main()` before `runApp`,
  // so here we just guarantee the push service provider is constructed
  // once and attach the auth-driven push registration hook to the
  // session lifecycle.
  ref.read(pushNotificationServiceProvider);
  ref.read(pushSessionHookProvider);
});
