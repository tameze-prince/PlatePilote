import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/secure_storage_service.dart';

/// Résout l'URL de base de l'API au démarrage de l'application.
///
/// Priorité : `--dart-define=PLATEPILOT_API_BASE_URL=...`, sinon `.env` (via
/// `flutter_dotenv`), sinon chaîne vide. Si vide au moment de
/// l'initialisation, une [StateError] est levée pour éviter les requêtes
/// silencieuses vers `localhost` en production.
String resolveApiBaseUrl() {
  const fromBuild = String.fromEnvironment(
    'PLATEPILOT_API_BASE_URL',
    defaultValue: '',
  );
  final fromEnv = dotenv.env['PLATEPILOT_API_BASE_URL'];
  final configured = fromBuild.isNotEmpty ? fromBuild : (fromEnv ?? '');
  if (configured.isEmpty) return '';

  final uri = Uri.tryParse(configured);
  if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
    throw StateError('PLATEPILOT_API_BASE_URL must be an absolute URL');
  }
  if (kReleaseMode && uri.scheme != 'https') {
    throw StateError('Release builds require an HTTPS API URL');
  }
  return configured;
}

/// Vérifie que la configuration est présente et lève une erreur explicite
/// sinon. Appelée une seule fois à l'init (provider).
void assertApiConfigured() {
  final url = resolveApiBaseUrl();
  if (url.isEmpty) {
    throw StateError(
      'PLATEPILOT_API_BASE_URL non configurée. '
      'Lancez l\u2019app avec `--dart-define=PLATEPILOT_API_BASE_URL=<url>` '
      'ou renseignez-la dans FrontEnd/.env.',
    );
  }
}

/// Fournit une instance [Dio] configurée avec l'URL de base, les timeouts,
/// les en-têtes par défaut et les intercepteurs d'authentification et d'erreur.
final dioProvider = Provider<Dio>((ref) {
  assertApiConfigured();
  final dio = Dio(
    BaseOptions(
      baseUrl: resolveApiBaseUrl(),
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: const {'Accept': 'application/json'},
      contentType: 'application/json',
    ),
  );

  final secureStorage = ref.read(secureStorageProvider);

  dio.interceptors.addAll([
    _AuthTokenInterceptor(
      tokenGetter: () => secureStorage.getAccessToken(),
      refreshTokenGetter: () => secureStorage.getRefreshToken(),
      onTokensRefreshed: (access, refresh) =>
          secureStorage.saveTokens(accessToken: access, refreshToken: refresh),
      onRefreshFailed: () => secureStorage.clearTokens(),
    ),
    _ErrorLogInterceptor(),
  ]);

  return dio;
});

/// Fournit une instance [ApiClient] pour effectuer les appels HTTP vers l'API.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class _AuthTokenInterceptor extends Interceptor {
  _AuthTokenInterceptor({
    required this.tokenGetter,
    required this.refreshTokenGetter,
    required this.onTokensRefreshed,
    required this.onRefreshFailed,
  });

  final Future<String?> Function() tokenGetter;
  final Future<String?> Function() refreshTokenGetter;
  final Future<void> Function(String access, String refresh) onTokensRefreshed;
  final Future<void> Function() onRefreshFailed;

  final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: resolveApiBaseUrl(),
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: const {'Accept': 'application/json'},
    ),
  );

  Future<_RefreshedTokens>? _refreshInFlight;

  Future<_RefreshedTokens> _refreshTokens(String refreshToken) {
    return _refreshInFlight ??= _performRefresh(refreshToken).whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<_RefreshedTokens> _performRefresh(String refreshToken) async {
    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      queryParameters: {'refreshToken': refreshToken},
    );
    final data = (response.data?['data'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final accessToken = data['accessToken'] as String?;
    final rotatedRefreshToken = data['refreshToken'] as String?;
    if (accessToken == null || accessToken.isEmpty ||
        rotatedRefreshToken == null || rotatedRefreshToken.isEmpty) {
      throw const FormatException('Refresh response is missing token fields');
    }
    await onTokensRefreshed(accessToken, rotatedRefreshToken);
    return _RefreshedTokens(accessToken);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenGetter();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // A previous request may already have rotated the token while this 401
    // was in flight. Retry with the latest access token instead of reusing a
    // now-revoked refresh token.
    final currentAccessToken = await tokenGetter();
    final authorization = err.requestOptions.headers['Authorization'];
    final failedAccessToken = authorization is String && authorization.startsWith('Bearer ')
        ? authorization.substring(7)
        : null;
    if (currentAccessToken != null && currentAccessToken != failedAccessToken) {
      await _retryWithAccessToken(err, currentAccessToken, handler);
      return;
    }

    final refreshToken = await refreshTokenGetter();
    if (refreshToken == null) {
      await onRefreshFailed();
      handler.next(err);
      return;
    }

    late final _RefreshedTokens refreshed;
    try {
      // Concurrent 401 responses share a single refresh-token rotation.
      refreshed = await _refreshTokens(refreshToken);
    } catch (_) {
      await onRefreshFailed();
      handler.next(err);
      return;
    }

    await _retryWithAccessToken(err, refreshed.accessToken, handler);
  }

  Future<void> _retryWithAccessToken(
    DioException err,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    final dio = Dio(BaseOptions(
      baseUrl: err.requestOptions.baseUrl,
      connectTimeout: err.requestOptions.connectTimeout,
      receiveTimeout: err.requestOptions.receiveTimeout,
      headers: err.requestOptions.headers,
      contentType: err.requestOptions.contentType,
    ));

    try {
      final retryResponse = await dio.fetch<Map<String, dynamic>>(err.requestOptions);
      handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }
}

class _RefreshedTokens {
  const _RefreshedTokens(this.accessToken);

  final String accessToken;
}

class _ErrorLogInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API Error] ${err.requestOptions.method} ${err.requestOptions.path} '
        'status=${err.response?.statusCode ?? "network"} type=${err.type.name}');
    handler.next(err);
  }
}

/// Client HTTP encapsulant [Dio] pour interagir avec l'API REST.
///
/// Fournit des méthodes génériques GET, POST, PUT, PATCH et DELETE.
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  /// Effectue une requête GET vers [path] avec des paramètres [query] optionnels.
  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) {
    return _dio.get(path, queryParameters: query);
  }

  /// Effectue une requête POST vers [path] avec un corps [data] et des paramètres [query] optionnels.
  Future<Response<dynamic>> post(String path, {Object? data, Map<String, dynamic>? query}) {
    return _dio.post(path, data: data, queryParameters: query);
  }

  /// Effectue une requête PUT vers [path] avec un corps [data] et des paramètres [query] optionnels.
  Future<Response<dynamic>> put(String path, {Object? data, Map<String, dynamic>? query}) {
    return _dio.put(path, data: data, queryParameters: query);
  }

  /// Effectue une requête PATCH vers [path] avec un corps [data] et des paramètres [query] optionnels.
  Future<Response<dynamic>> patch(String path, {Object? data, Map<String, dynamic>? query}) {
    return _dio.patch(path, data: data, queryParameters: query);
  }

  /// Effectue une requête DELETE vers [path].
  Future<Response<dynamic>> delete(String path) {
    return _dio.delete(path);
  }
}
