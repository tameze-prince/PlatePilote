import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_provider.dart';

class AppSessionState {
  const AppSessionState({
    required this.hasSeenOnboarding,
    required this.isAuthenticated,
  });

  final bool hasSeenOnboarding;
  final bool isAuthenticated;

  AppSessionState copyWith({bool? hasSeenOnboarding, bool? isAuthenticated}) {
    return AppSessionState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AppSessionNotifier extends Notifier<AppSessionState> {
  static const _hasSeenOnboardingKey = 'hasSeenOnboarding';
  static const _isAuthenticatedKey = 'isAuthenticated';

  @override
  AppSessionState build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    return AppSessionState(
      hasSeenOnboarding: preferences.getBool(_hasSeenOnboardingKey) ?? false,
      isAuthenticated: preferences.getBool(_isAuthenticatedKey) ?? false,
    );
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasSeenOnboarding: true);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_hasSeenOnboardingKey, true);
  }

  Future<void> signIn() async {
    state = state.copyWith(isAuthenticated: true);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_isAuthenticatedKey, true);
  }

  Future<void> signOut() async {
    state = state.copyWith(isAuthenticated: false);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_isAuthenticatedKey, false);
  }
}

final appSessionProvider =
    NotifierProvider<AppSessionNotifier, AppSessionState>(
      AppSessionNotifier.new,
    );
