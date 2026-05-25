import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_pilote/core/network/api_client.dart';
import 'package:plate_pilote/core/providers/app_session_provider.dart';
import 'package:plate_pilote/core/providers/preferences_provider.dart';
import 'package:plate_pilote/core/repositories/auth_repository.dart';
import 'package:plate_pilote/core/services/secure_storage_service.dart';
import 'package:plate_pilote/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTokenStorage extends TokenStorage {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<bool> hasTokens() async => accessToken != null;
}

class MockAuthRepository extends AuthRepository {
  MockAuthRepository() : super(ApiClient(Dio()));

  bool validateSuccess = false;
  bool refreshSuccess = false;
  String? refreshedAccess;
  String? refreshedRefresh;
  bool loginSuccess = false;
  String? loginAccess;
  String? loginRefresh;
  bool logoutSuccess = true;

  @override
  Future<AuthResult> validateSession() async {
    return AuthResult(success: validateSuccess);
  }

  @override
  Future<AuthResult> refreshToken(String refreshToken) async {
    return AuthResult(
      success: refreshSuccess,
      accessToken: refreshedAccess,
      refreshToken: refreshedRefresh,
    );
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    return AuthResult(
      success: loginSuccess,
      accessToken: loginAccess,
      refreshToken: loginRefresh,
    );
  }

  @override
  Future<bool> logout({required String refreshToken}) async => true;
}

ProviderContainer createContainer({
  required SharedPreferences prefs,
  MockTokenStorage? tokenStorage,
  MockAuthRepository? authRepo,
}) {
  return ProviderContainer(
    overrides: [
      if (tokenStorage != null)
        secureStorageProvider.overrideWithValue(tokenStorage),
      if (authRepo != null)
        authRepositoryProvider.overrideWithValue(authRepo),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
}

void main() {
  group('AuthNotifier.checkSession', () {
    test('does nothing when no tokens exist', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = MockTokenStorage();
      final container = createContainer(
        prefs: prefs,
        tokenStorage: storage,
      );

      await container.read(authProvider.notifier).checkSession();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
    });

    test('sets authenticated when tokens are valid', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = MockTokenStorage();
      await storage.saveTokens(
        accessToken: 'valid_token', refreshToken: 'valid_refresh');
      final authRepo = MockAuthRepository();
      authRepo.validateSuccess = true;

      final container = createContainer(
        prefs: prefs,
        tokenStorage: storage,
        authRepo: authRepo,
      );

      await container.read(authProvider.notifier).checkSession();

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      final session = container.read(appSessionProvider);
      expect(session.isAuthenticated, true);
    });

    test('clears tokens and signs out when refresh fails', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = MockTokenStorage();
      await storage.saveTokens(
        accessToken: 'expired_token', refreshToken: 'expired_refresh');
      final authRepo = MockAuthRepository();
      authRepo.validateSuccess = false;
      authRepo.refreshSuccess = false;

      final container = createContainer(
        prefs: prefs,
        tokenStorage: storage,
        authRepo: authRepo,
      );

      await container.read(authProvider.notifier).checkSession();

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(storage.accessToken, isNull);
      final session = container.read(appSessionProvider);
      expect(session.isAuthenticated, false);
    });

    test('saves new tokens and sets authenticated on refresh success', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = MockTokenStorage();
      await storage.saveTokens(
        accessToken: 'expired', refreshToken: 'valid_refresh');
      final authRepo = MockAuthRepository();
      authRepo.validateSuccess = false;
      authRepo.refreshSuccess = true;
      authRepo.refreshedAccess = 'new_access';
      authRepo.refreshedRefresh = 'new_refresh';

      final container = createContainer(
        prefs: prefs,
        tokenStorage: storage,
        authRepo: authRepo,
      );

      await container.read(authProvider.notifier).checkSession();

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(storage.accessToken, 'new_access');
      expect(storage.refreshToken, 'new_refresh');
      final session = container.read(appSessionProvider);
      expect(session.isAuthenticated, true);
    });
  });

  group('AuthNotifier.login', () {
    test('sets authenticated on success and syncs session', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = MockTokenStorage();
      final authRepo = MockAuthRepository();
      authRepo.loginSuccess = true;
      authRepo.loginAccess = 'access_token';
      authRepo.loginRefresh = 'refresh_token';

      final container = createContainer(
        prefs: prefs,
        tokenStorage: storage,
        authRepo: authRepo,
      );

      final result = await container.read(authProvider.notifier).login(
        email: 'test@test.com',
        password: 'password',
      );

      expect(result, true);
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.email, 'test@test.com');
      expect(storage.accessToken, 'access_token');
      final session = container.read(appSessionProvider);
      expect(session.isAuthenticated, true);
    });

    test('sets error message on failure', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = MockTokenStorage();
      final authRepo = MockAuthRepository();
      authRepo.loginSuccess = false;

      final container = createContainer(
        prefs: prefs,
        tokenStorage: storage,
        authRepo: authRepo,
      );

      final result = await container.read(authProvider.notifier).login(
        email: 'test@test.com',
        password: 'wrong',
      );

      expect(result, false);
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
    });
  });

  group('AuthNotifier.logout', () {
    test('clears tokens, resets state, and signs out session', () async {
      SharedPreferences.setMockInitialValues({
        'isAuthenticated': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = MockTokenStorage();
      await storage.saveTokens(
        accessToken: 'token', refreshToken: 'refresh');
      final authRepo = MockAuthRepository();

      final container = createContainer(
        prefs: prefs,
        tokenStorage: storage,
        authRepo: authRepo,
      );

      await container.read(authProvider.notifier).logout();

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(storage.accessToken, isNull);
      final session = container.read(appSessionProvider);
      expect(session.isAuthenticated, false);
    });
  });

  group('AppSessionProvider sync', () {
    test('isAuthenticated defaults to false', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs: prefs);

      final session = container.read(appSessionProvider);
      expect(session.isAuthenticated, false);
      expect(session.hasSeenOnboarding, false);
    });

    test('signIn and signOut toggle isAuthenticated', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs: prefs);

      await container.read(appSessionProvider.notifier).signIn();
      expect(container.read(appSessionProvider).isAuthenticated, true);
      expect(prefs.getBool('isAuthenticated'), true);

      await container.read(appSessionProvider.notifier).signOut();
      expect(container.read(appSessionProvider).isAuthenticated, false);
      expect(prefs.getBool('isAuthenticated'), false);
    });

    test('completeOnboarding persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs: prefs);

      await container.read(appSessionProvider.notifier).completeOnboarding();
      expect(container.read(appSessionProvider).hasSeenOnboarding, true);
      expect(prefs.getBool('hasSeenOnboarding'), true);
    });
  });
}