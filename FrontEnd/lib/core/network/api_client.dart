import 'package:dio/dio.dart';
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
  if (fromBuild.isNotEmpty) return fromBuild;
  final fromEnv = dotenv.env['PLATEPILOT_API_BASE_URL'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  return '';
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

    final refreshToken = await refreshTokenGetter();
    if (refreshToken == null) {
      await onRefreshFailed();
      handler.next(err);
      return;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        queryParameters: {'refreshToken': refreshToken},
      );

      final data = (response.data?['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      await onTokensRefreshed(newAccessToken, newRefreshToken);

      // Retry the original request with the new token using the original Dio
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      
      // Use the Dio from the request options to retry
      final dio = Dio(BaseOptions(
        baseUrl: err.requestOptions.baseUrl,
        connectTimeout: err.requestOptions.connectTimeout,
        receiveTimeout: err.requestOptions.receiveTimeout,
        headers: err.requestOptions.headers,
        contentType: err.requestOptions.contentType,
      ));
      
      final retryResponse = await dio.fetch<Map<String, dynamic>>(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await onRefreshFailed();
      handler.next(err);
    }
  }
}

class _ErrorLogInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API Error] ${err.requestOptions.uri} - ${err.message}');
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
