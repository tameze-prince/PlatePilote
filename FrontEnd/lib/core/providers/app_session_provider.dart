import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_provider.dart';

/// État de la session utilisateur : onboarding vu et authentification.
class AppSessionState {
  /// Crée un [AppSessionState] avec les valeurs initiales.
  const AppSessionState({
    required this.hasSeenOnboarding,
    required this.isAuthenticated,
    required this.hasAcceptedBetaAnalytics,
    required this.hasAcceptedPush,
  });

  /// Indique si l'utilisateur a déjà vu l'onboarding.
  final bool hasSeenOnboarding;

  /// Indique si l'utilisateur est authentifié.
  final bool isAuthenticated;

  /// Indique si l'utilisateur a accepté l'analytics obligatoire de la beta.
  final bool hasAcceptedBetaAnalytics;

  /// Indique si l'utilisateur a accepté les notifications push côté app.
  final bool hasAcceptedPush;

  /// Crée une copie avec des champs optionnellement modifiés.
  AppSessionState copyWith({
    bool? hasSeenOnboarding,
    bool? isAuthenticated,
    bool? hasAcceptedBetaAnalytics,
    bool? hasAcceptedPush,
  }) {
    return AppSessionState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasAcceptedBetaAnalytics:
          hasAcceptedBetaAnalytics ?? this.hasAcceptedBetaAnalytics,
      hasAcceptedPush: hasAcceptedPush ?? this.hasAcceptedPush,
    );
  }
}

/// Notifier Riverpod qui gère l'état de session (onboarding et auth) dans SharedPreferences.
class AppSessionNotifier extends Notifier<AppSessionState> {
  static const _hasSeenOnboardingKey = 'hasSeenOnboarding';
  static const _isAuthenticatedKey = 'isAuthenticated';
  static const analyticsConsentKey = 'analytics_consent_granted';
  static const pushConsentKey = 'push_consent_granted';

  @override
  AppSessionState build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    return AppSessionState(
      hasSeenOnboarding: preferences.getBool(_hasSeenOnboardingKey) ?? false,
      isAuthenticated: preferences.getBool(_isAuthenticatedKey) ?? false,
      hasAcceptedBetaAnalytics:
          preferences.getBool(analyticsConsentKey) ?? false,
      hasAcceptedPush: preferences.getBool(pushConsentKey) ?? false,
    );
  }

  /// Marque l'onboarding comme terminé dans SharedPreferences.
  Future<void> completeOnboarding() async {
    state = state.copyWith(hasSeenOnboarding: true);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_hasSeenOnboardingKey, true);
  }

  /// Connecte l'utilisateur et persiste l'état dans SharedPreferences.
  Future<void> signIn() async {
    state = state.copyWith(isAuthenticated: true);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_isAuthenticatedKey, true);
  }

  /// Déconnecte l'utilisateur et met à jour SharedPreferences.
  Future<void> signOut() async {
    state = state.copyWith(isAuthenticated: false);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_isAuthenticatedKey, false);
  }

  /// Persiste les consentements beta.
  Future<void> acceptBetaConsent({required bool pushConsent}) async {
    state = state.copyWith(
      hasAcceptedBetaAnalytics: true,
      hasAcceptedPush: pushConsent,
    );
    final preferences = ref.read(sharedPreferencesProvider);
    await preferences.setBool(analyticsConsentKey, true);
    await preferences.setBool(pushConsentKey, pushConsent);
  }

  /// Révoque les statistiques d'usage et bloque à nouveau l'accès beta.
  Future<void> revokeAnalyticsConsent() async {
    state = state.copyWith(hasAcceptedBetaAnalytics: false);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(analyticsConsentKey, false);
  }
}

/// Provider Riverpod exposant [AppSessionState] et [AppSessionNotifier]
/// pour la gestion de la session utilisateur.
final appSessionProvider =
    NotifierProvider<AppSessionNotifier, AppSessionState>(
      AppSessionNotifier.new,
    );
