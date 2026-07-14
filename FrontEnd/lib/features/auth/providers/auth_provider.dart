import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_session_provider.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/oauth2_repository.dart';
import '../../../core/repositories/preference_repository.dart';
import '../../../core/repositories/profile_repository.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../onboarding/onboarding_state.dart';
import 'auth_state.dart';

/// Notifier qui gère l'état d'authentification.
/// Vérifie la session, connecte/déconnecte l'utilisateur et gère les tokens.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  /// Vérifie la session existante et tente un refresh si les tokens sont expirés.
  Future<void> checkSession() async {
    final secureStorage = ref.read(secureStorageProvider);
    final hasTokens = await secureStorage.hasTokens();
    if (!hasTokens) return;

    final accessToken = await secureStorage.getAccessToken();
    if (accessToken == null) return;

    state = const AuthState(isLoading: true);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.validateSession();

    if (result.success) {
      final email = AuthRepository.extractEmailFromToken(accessToken);
      state = AuthState(
        isAuthenticated: true,
        email: email,
      );
      await ref.read(appSessionProvider.notifier).signIn();
    } else {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken != null) {
        final refreshResult = await repo.refreshToken(refreshToken);
        if (refreshResult.success &&
            refreshResult.accessToken != null &&
            refreshResult.refreshToken != null) {
          await secureStorage.saveTokens(
            accessToken: refreshResult.accessToken!,
            refreshToken: refreshResult.refreshToken!,
          );
          final email =
              AuthRepository.extractEmailFromToken(refreshResult.accessToken!);
          state = AuthState(
            isAuthenticated: true,
            email: email,
          );
          await ref.read(appSessionProvider.notifier).signIn();
          return;
        }
      }
      await secureStorage.clearTokens();
      state = const AuthState();
      await ref.read(appSessionProvider.notifier).signOut();
    }
  }

  /// Connecte l'utilisateur avec email et mot de passe.
  /// Retourne true si la connexion a réussi.
  Future<bool> login({required String email, required String password}) async {
    state = const AuthState(isLoading: true);

    final repo = ref.read(authRepositoryProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final result = await repo.login(email: email, password: password);

    if (result.success && result.accessToken != null && result.refreshToken != null) {
      await secureStorage.saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken!,
      );

      state = AuthState(
        isAuthenticated: true,
        email: email,
      );
      await ref.read(appSessionProvider.notifier).signIn();
      return true;
    }

    state = AuthState(errorMessage: result.message ?? 'Login failed');
    return false;
  }

  /// Enregistre un nouvel utilisateur.
  /// Retourne true si l'inscription a réussi.
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = const AuthState(isLoading: true);

    final repo = ref.read(authRepositoryProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final result = await repo.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    if (result.success && result.accessToken != null && result.refreshToken != null) {
      await secureStorage.saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken!,
      );

      state = AuthState(
        isAuthenticated: true,
        email: email,
        name: '$firstName $lastName',
      );
      await ref.read(appSessionProvider.notifier).signIn();

      await _syncOnboardingPreferences();
      await ref.read(appSessionProvider.notifier).completeOnboarding();

      return true;
    }

    state = AuthState(errorMessage: result.message ?? 'Registration failed');
    return false;
  }

  /// Synchronise les préférences de l'onboarding avec le profil utilisateur.
  Future<void> _syncOnboardingPreferences() async {
    try {
      final onboarding = ref.read(onboardingProvider);

      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.updateProfile(
        householdSize: int.tryParse(onboarding.householdSize ?? ''),
        cookingSkill: onboarding.cookingSkill,
        healthGoals: onboarding.goals.isNotEmpty
            ? onboarding.goals.join(', ')
            : null,
      );

      final prefRepo = ref.read(preferenceRepositoryProvider);
      for (final diet in onboarding.dietaryPreferences) {
        try {
          await prefRepo.addDietaryPreference(diet);
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Vérifie l'email avec le token fourni.
  Future<bool> verifyEmail(String token) async {
    final repo = ref.read(authRepositoryProvider);
    final success = await repo.verifyEmail(token);
    if (!success) {
      state = state.copyWith(errorMessage: 'Email verification failed');
    }
    return success;
  }

  /// Renvoie l'email de vérification.
  Future<bool> resendVerification({required String email}) async {
    final repo = ref.read(authRepositoryProvider);
    return repo.resendVerification(email);
  }

  /// Connecte l'utilisateur avec Google OAuth2.
  Future<bool> signInWithGoogle() async {
    state = const AuthState(isLoading: true);
    try {
      final repo = ref.read(oAuth2RepositoryProvider);
      final result = await repo.signInWithGoogle();
      if (result == null) {
        state = const AuthState(); // User cancelled
        return false;
      }
      if (!result.success) {
        state = AuthState(errorMessage: result.errorMessage);
        return false;
      }
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken!,
      );
      final email = AuthRepository.extractEmailFromToken(result.accessToken!);
      state = AuthState(isAuthenticated: true, email: email);
      await ref.read(appSessionProvider.notifier).signIn();
      return true;
    } catch (e) {
      state = AuthState(errorMessage: 'Google sign-in failed');
      return false;
    }
  }

  /// Connecte l'utilisateur avec Apple OAuth2.
  Future<bool> signInWithApple() async {
    state = const AuthState(isLoading: true);
    try {
      final repo = ref.read(oAuth2RepositoryProvider);
      final result = await repo.signInWithApple();
      if (result == null) {
        state = const AuthState(); // User cancelled
        return false;
      }
      if (!result.success) {
        state = AuthState(errorMessage: result.errorMessage);
        return false;
      }
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.saveTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken!,
      );
      final email = AuthRepository.extractEmailFromToken(result.accessToken!);
      state = AuthState(isAuthenticated: true, email: email);
      await ref.read(appSessionProvider.notifier).signIn();
      return true;
    } catch (e) {
      state = AuthState(errorMessage: 'Apple sign-in failed');
      return false;
    }
  }

  /// Déconnecte l'utilisateur et efface les tokens.
  Future<void> logout() async {
    final secureStorage = ref.read(secureStorageProvider);
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken != null) {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout(refreshToken: refreshToken);
    }
    await secureStorage.clearTokens();
    state = const AuthState();
    await ref.read(appSessionProvider.notifier).signOut();
  }
}

/// Fournisseur global de l'état d'authentification.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
