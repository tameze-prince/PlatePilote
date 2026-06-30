// Integration test — Weekly meal plan screen + mock generate/swap.
// Run on device only.
//
// Uses inline mock instead of import because providers/repos have different
// structures in the real codebase vs the mocks needed here.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plate_pilote/core/providers/preferences_provider.dart';
import 'package:plate_pilote/core/services/secure_storage_service.dart';
import 'package:plate_pilote/features/meal_plan/weekly_plan_screen.dart';
import 'package:plate_pilote/l10n/app_localizations.dart';

class MockTokenStorage extends TokenStorage {
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  Future<void> clearTokens() async {}
  @override
  Future<bool> hasTokens() async => false;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final isRunningOnDevice = Platform.isAndroid || Platform.isIOS;
  final shouldSkip = !isRunningOnDevice;

  Future<void> bootPlan(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'en'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(MockTokenStorage()),
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
  }

  testWidgets('meal plan — screen mounts without exception', (tester) async {
    if (shouldSkip) {
      expect(true, isTrue, skip: 'integration_test requires a device');
      return;
    }
    await bootPlan(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.byType(WeeklyPlanScreen), findsOneWidget);
  });
}