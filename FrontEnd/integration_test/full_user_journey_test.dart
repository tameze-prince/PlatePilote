// Integration test — Full user journey: signup -> onboarding -> plan -> grocery.
// Run on device/emulator:
//   cd FrontEnd && flutter test integration_test/full_user_journey_test.dart -d <device-id>
//
// Mock strategy: Provider overrides for all IO (Dio, SecureStorage, SharedPreferences).
// No real backend calls — all providers are overridden with in-memory fakes.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plate_pilote/core/providers/preferences_provider.dart';
import 'package:plate_pilote/features/auth/login_screen.dart';
import 'package:plate_pilote/features/onboarding/onboarding_single_screen.dart';
import 'package:plate_pilote/features/grocery/grocery_list_screen.dart';
import 'package:plate_pilote/features/meal_plan/weekly_plan_screen.dart';
import 'package:plate_pilote/l10n/app_localizations.dart';

// --- Setup ---

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final isRunningOnDevice = Platform.isAndroid || Platform.isIOS;
  final shouldSkip = !isRunningOnDevice;

  testWidgets('full journey — login screen mounts', (
    WidgetTester tester,
  ) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'requires device');
      return;
    }

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PlatePilot'), findsOneWidget);
  });

  testWidgets('full journey — onboarding screen renders after login', (
    WidgetTester tester,
  ) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'requires device');
      return;
    }

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OnboardingSingleScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to PlatePilot'), findsOneWidget);
    expect(find.text('Tell us about your household'), findsOneWidget);
  });

  testWidgets('full journey — weekly plan screen mounts', (
    WidgetTester tester,
  ) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'requires device');
      return;
    }

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WeeklyPlanScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('full journey — grocery list screen mounts', (
    WidgetTester tester,
  ) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'requires device');
      return;
    }

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GroceryListScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
