import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_response.dart';

/// Repository de base fournissant des méthodes génériques pour traiter
/// les réponses HTTP (objet unique, liste et paginée) ainsi que l'extraction
/// de messages d'erreur à partir des exceptions [DioException].
class BaseRepository {
  const BaseRepository(this.apiClient);

  /// Instance du client API pour effectuer les requêtes.
  final ApiClient apiClient;

  /// Traite une réponse HTTP et convertit l'objet `data` via [fromJson].
  /// Lance [ApiException] en cas d'échec.
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

  /// Traite une réponse HTTP et convertit la liste `data` via [fromJson].
  /// Lance [ApiException] en cas d'échec.
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

  /// Traite une réponse HTTP paginée et retourne une [PageResponse].
  /// Lance [ApiException] en cas d'échec.
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

  /// Extrait un message d'erreur lisible depuis une [DioException].
  /// Vérifie d'abord le champ `message` de la réponse, puis utilise
  /// un message par défaut selon le type d'exception.
  String extractMessage(DioException e) {
    final response = e.response;
    if (response?.data is Map) {
      final msg = (response!.data as Map)['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Server is not responding (timeout). Please check that the backend is running.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out while sending data.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Please check your connection and ensure the backend is running on port 8081.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode ?? "unknown"})';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Exception levée par les repositories lors d'une erreur API.
class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  /// Message décrivant l'erreur.
  final String message;

  /// Code HTTP de la réponse, ou null si indisponible.
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
