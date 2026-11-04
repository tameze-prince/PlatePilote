import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/notifications/notification_service.dart';
import 'core/providers/preferences_provider.dart';
import 'firebase_options.dart';

/// Point d'entrée de l'application PlatePilot.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseOptions = DefaultFirebaseOptions.currentPlatformOrNull;
  if (firebaseOptions != null) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
    } catch (e, st) {
      debugPrint('Firebase init failed (non-blocking): $e\n$st');
    }
  } else {
    debugPrint(
      'Firebase is not configured; remote push notifications are disabled.',
    );
  }
  final preferences = await SharedPreferences.getInstance();
  await NotificationService.instance.initialize();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const PlatePilotApp(),
    ),
  );
}
