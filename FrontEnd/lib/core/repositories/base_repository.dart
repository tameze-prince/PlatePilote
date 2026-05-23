import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_response.dart';

class BaseRepository {
  const BaseRepository(this.apiClient);

  final ApiClient apiClient;

  T handleResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = body['data'];
      if (data != null && data is Map<String, dynamic>) {
        return fromJson(data);
      }
      throw ApiException('Response data is missing or invalid', response.statusCode);
    }
    throw ApiException(
      (body['message'] as String?) ?? 'Unexpected error',
      response.statusCode,
    );
  }

  List<T> handleListResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = body['data'];
      if (data != null && data is List) {
        return data
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ApiException('Response data is missing or invalid', response.statusCode);
    }
    throw ApiException(
      (body['message'] as String?) ?? 'Unexpected error',
      response.statusCode,
    );
  }

  PageResponse<T> handlePageResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = body['data'];
      if (data != null && data is Map<String, dynamic>) {
        return PageResponse.fromJson(data, fromJson);
      }
      throw ApiException('Page response data is missing or invalid', response.statusCode);
    }
    throw ApiException(
      (body['message'] as String?) ?? 'Unexpected error',
      response.statusCode,
    );
  }

  String extractMessage(DioException e) {
    final response = e.response;
    if (response?.data is Map) {
      final msg = (response!.data as Map)['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return 'An unexpected error occurred';
  }
}

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
