import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration is injected at build time by the owner.
///
/// When the Firebase variables are absent, Firebase/FCM remains disabled.
/// This prevents fake placeholder credentials from being shipped in releases.
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatformOrNull {
    if (kIsWeb) {
      return _options(
        apiKey: const String.fromEnvironment('FIREBASE_WEB_API_KEY'),
        appId: const String.fromEnvironment('FIREBASE_WEB_APP_ID'),
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _options(
          apiKey: const String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
          appId: const String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _options(
          apiKey: const String.fromEnvironment('FIREBASE_IOS_API_KEY'),
          appId: const String.fromEnvironment('FIREBASE_IOS_APP_ID'),
          iosBundleId: const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static FirebaseOptions? _options({
    required String apiKey,
    required String appId,
    String? iosBundleId,
  }) {
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
    );
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

    if (apiKey.isEmpty ||
        appId.isEmpty ||
        messagingSenderId.isEmpty ||
        projectId.isEmpty) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      iosBundleId: iosBundleId?.isEmpty == true ? null : iosBundleId,
    );
  }
}
