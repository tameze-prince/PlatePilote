import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'base_repository.dart';

/// Repository des recommandations personnalisées et suggestions de repas.
class RecommendationRepository extends BaseRepository {
  RecommendationRepository(super.apiClient);

  /// Récupère une liste de recommandations personnalisées.
  Future<List<Map<String, dynamic>>> getRecommendations({int limit = 10}) async {
    try {
      final response = await apiClient.get('/recommendations', query: {'limit': limit});
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère des suggestions de repas rapides (temps max configurable).
  Future<List<Map<String, dynamic>>> getQuickMeals({int maxTime = 30, int limit = 3}) async {
    try {
      final response = await apiClient.post(
        '/recommendations/quick-meal',
        query: {'maxTime': maxTime, 'limit': limit},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Génère un plan de repas hebdomadaire complet.
  Future<List<List<Map<String, dynamic>>>> generateWeeklyPlan() async {
    try {
      final response = await apiClient.post('/recommendations/weekly-plan');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data
            .map((day) => (day as List).cast<Map<String, dynamic>>())
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

/// Provider Riverpod pour [RecommendationRepository].
final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepository(ref.watch(apiClientProvider));
});
