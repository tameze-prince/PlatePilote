import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_pilote/core/providers/preferences_provider.dart';
import 'package:plate_pilote/features/auth/providers/auth_provider.dart';
import 'package:plate_pilote/features/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _BlockingAuthNotifier extends AuthNotifier {
  @override
  Future<void> checkSession() => Completer<void>().future;
}

void main() {
  testWidgets('SplashScreen renders while the startup session check is pending', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          authProvider.overrideWith(_BlockingAuthNotifier.new),
        ],
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PlatePilot'), findsOneWidget);
    expect(find.text('Your smart meal co-pilot'), findsOneWidget);
  });
}
