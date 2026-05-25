import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'PLATEPILOT_API_BASE_URL',
        defaultValue: 'http://localhost:8081/api/v1',
      ),
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
      baseUrl: const String.fromEnvironment(
        'PLATEPILOT_API_BASE_URL',
        defaultValue: 'http://localhost:8081/api/v1',
      ),
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
      final response = await _refreshDio.post(
        '/auth/refresh',
        queryParameters: {'refreshToken': refreshToken},
      );

      final data = response.data['data'] as Map<String, dynamic>;
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
      
      final retryResponse = await dio.fetch(err.requestOptions);
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

class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) {
    return _dio.get(path, queryParameters: query);
  }

  Future<Response<dynamic>> post(String path, {Object? data, Map<String, dynamic>? query}) {
    return _dio.post(path, data: data, queryParameters: query);
  }

  Future<Response<dynamic>> put(String path, {Object? data}) {
    return _dio.put(path, data: data);
  }

  Future<Response<dynamic>> patch(String path, {Object? data, Map<String, dynamic>? query}) {
    return _dio.patch(path, data: data, queryParameters: query);
  }

  Future<Response<dynamic>> delete(String path) {
    return _dio.delete(path);
  }
}
