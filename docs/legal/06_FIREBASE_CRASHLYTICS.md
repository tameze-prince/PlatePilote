# Firestore Options — Config Firebase réelle

**Action manuelle** (Prince, 1 fois seulement) :
```bash
cd ~/Documents/PlatePilote/FrontEnd
firebase login
firebase use platepilote-dev
flutterfire configure --project=platepilote-dev
```

Ceci remplace : `FrontEnd/lib/firebase_options.dart` (placeholder actuel par la vraie config).

## Crashlytics + Sentry

**Crashlytics** (via Firebase) :
```yaml
# pubspec.yaml
  firebase_crashlytics: ^4.0.0
```

Dans `main()` :
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Captures non-fatals
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
```

**Alternative Sentry** (si tu préfères un provider unifié) :
```yaml
  sentry_flutter: ^8.0.0
  sentry_dart_io: ^8.0.0
```