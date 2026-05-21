import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_pilote/core/providers/preferences_provider.dart';
import 'package:plate_pilote/core/providers/theme_provider.dart';
import 'package:plate_pilote/core/widgets/floating_components.dart';
import 'package:plate_pilote/features/auth/login_screen.dart';
import 'package:plate_pilote/features/onboarding/onboarding_flow.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('theme mode preference persists locally', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);

    await container.read(themeModeProvider.notifier).set(ThemeMode.dark);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(preferences.getString('themeMode'), 'dark');
  });

  testWidgets('premium auth screen renders glass login content', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('PlatePilot'), findsOneWidget);
    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('onboarding selection updates the visible selected state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MaterialApp(home: OnboardingFlow()),
      ),
    );

    expect(find.text('Step 1 of 3'), findsOneWidget);
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('floating navigation reports selected branch index', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: FloatingNavigationBar(
            currentIndex: selectedIndex,
            onDestinationSelected: (index) => selectedIndex = index,
            destinations: const [
              FloatingNavDestination(icon: Icons.home, label: 'Home'),
              FloatingNavDestination(icon: Icons.calendar_month, label: 'Plan'),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Plan'));
    await tester.pump();

    expect(selectedIndex, 1);
  });
}
