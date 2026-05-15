import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_pilote/app/app.dart';
import 'package:plate_pilote/core/providers/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PlatePilot renders the splash experience', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const PlatePilotApp(),
      ),
    );

    expect(find.text('PlatePilot'), findsOneWidget);
    expect(find.text('Your smart meal co-pilot'), findsOneWidget);
  });
}
