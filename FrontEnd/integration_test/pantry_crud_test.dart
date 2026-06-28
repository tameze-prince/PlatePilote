// Integration test — Pantry screen smoke.
// Run on device only.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plate_pilote/core/providers/preferences_provider.dart';
import 'package:plate_pilote/features/pantry/pantry_screen.dart';
import 'package:plate_pilote/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final isRunningOnDevice = Platform.isAndroid || Platform.isIOS;
  final shouldSkip = !isRunningOnDevice;

  Future<void> bootPantry(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'en'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PantryScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('pantry — screen mounts and search field renders', (
    tester,
  ) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'integration_test requires a device');
      return;
    }
    await bootPantry(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    expect(find.byType(PantryScreen), findsOneWidget);
  });
}
