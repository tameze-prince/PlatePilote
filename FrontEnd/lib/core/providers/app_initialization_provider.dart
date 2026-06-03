import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/notification_service.dart';

/// Provider qui initialise les services au démarrage de l'application
/// (notifications locales, etc.). À attendre dans le splash screen.
final appInitializationProvider = FutureProvider<void>((ref) async {
  await NotificationService.instance.initialize();
});
