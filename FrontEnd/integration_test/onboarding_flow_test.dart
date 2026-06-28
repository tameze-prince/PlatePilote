// Integration test — Onboarding single screen smoke.
// Run on device only (flutter test integration_test/onboarding_flow_test.dart -d <id>)

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plate_pilote/core/providers/preferences_provider.dart';
import 'package:plate_pilote/features/onboarding/onboarding_single_screen.dart';
import 'package:plate_pilote/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final isRunningOnDevice = Platform.isAndroid || Platform.isIOS;
  final shouldSkip = !isRunningOnDevice;

  Future<void> bootOnboarding(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'en'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingSingleScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding renders household + cooking profile sections', (
    tester,
  ) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'integration_test requires a device');
      return;
    }
    await bootOnboarding(tester);

    expect(find.text('Welcome to PlatePilot'), findsOneWidget);
    expect(find.text('Tell us about your household'), findsOneWidget);
    expect(find.byType(OnboardingSingleScreen), findsOneWidget);
  });

  testWidgets('onboarding — scroll cycles through sections without crash', (
    tester,
  ) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'integration_test requires a device');
      return;
    }
    await bootOnboarding(tester);

    final scrollable = find.byType(Scrollable).first;
    // We only verify scrollability — content varies by locale.
    expect(scrollable, findsOneWidget);
    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
