import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_session_provider.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/services/secure_storage_service.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

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
    }
  }

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
      return true;
    }

    state = AuthState(errorMessage: result.message ?? 'Registration failed');
    return false;
  }

  Future<bool> verifyEmail(String token) async {
    final repo = ref.read(authRepositoryProvider);
    final success = await repo.verifyEmail(token);
    if (!success) {
      state = state.copyWith(errorMessage: 'Email verification failed');
    }
    return success;
  }

  Future<bool> resendVerification({required String email}) async {
    final repo = ref.read(authRepositoryProvider);
    return repo.resendVerification(email);
  }

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

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
