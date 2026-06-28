// Integration test — Smoke auth flow.
// Runs only on a real device/emulator (`flutter test integration_test/`).
// `flutter test` (no device) skips via the isRunningOnDevice guard.
//
// Run on device:
//   cd FrontEnd
//   flutter test integration_test/smoke_auth_test.dart \
//     -d <emulator-id> \
//     --dart-define=PLATEPILOT_API_BASE_URL=https://staging.example.com

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plate_pilote/core/providers/preferences_provider.dart';
import 'package:plate_pilote/features/auth/login_screen.dart';
import 'package:plate_pilote/l10n/app_localizations.dart';
import 'package:plate_pilote/core/widgets/floating_components.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Skip when not on a physical device/emulator.
  final isRunningOnDevice = Platform.isAndroid || Platform.isIOS;
  final shouldSkip = !isRunningOnDevice;

  Future<void> bootApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('smoke — login screen renders brand + primary CTA', (
    tester,
  ) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'integration_test requires a device');
      return;
    }
    await bootApp(tester);

    expect(find.text('PlatePilot'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('smoke — bottom navigation tabs are reactive', (tester) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'integration_test requires a device');
      return;
    }
    var selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: FloatingNavigationBar(
            currentIndex: selectedIndex,
            onDestinationSelected: (i) => selectedIndex = i,
            destinations: const [
              FloatingNavDestination(icon: Icons.restaurant, label: 'Plan'),
              FloatingNavDestination(icon: Icons.kitchen, label: 'Grocery'),
              FloatingNavDestination(icon: Icons.shelves, label: 'Pantry'),
              FloatingNavDestination(icon: Icons.settings, label: 'Settings'),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pantry'));
    await tester.pump();
    expect(selectedIndex, 2);
  });
}
