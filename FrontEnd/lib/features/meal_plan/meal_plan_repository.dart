import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/meal_plan.dart';

/// Dépôt des plans de repas.
/// Communique avec l'API pour gérer les plans, leurs entrées et les swaps.
class MealPlanRepository extends BaseRepository {
  MealPlanRepository(super.apiClient);

  /// Récupère la liste paginée des plans de repas.
  Future<PageResponse<MealPlan>> listMealPlans({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/meal-plans',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère un plan de repas par son identifiant.
  Future<MealPlan> getMealPlan(String id) async {
    try {
      final response = await apiClient.get('/meal-plans/$id');
      return handleResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Crée un nouveau plan de repas.
  Future<MealPlan> createMealPlan({
    required String name,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await apiClient.post('/meal-plans', data: {
        'name': name,
        'startDate': startDate,
        'endDate': endDate,
      });
      return handleResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Génère un plan hebdomadaire à partir d'une date de début.
  Future<MealPlan> generateWeeklyPlan({required String startDate}) async {
    try {
      final response = await apiClient.post(
        '/meal-plans/generate',
        query: {'startDate': startDate},
      );
      return handleResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Ajoute une entrée (repas) à un plan.
  Future<MealPlan> addEntry(
    String planId, {
    required String recipeId,
    required String mealDate,
    required String mealType,
    int servings = 1,
    String? notes,
  }) async {
    try {
      final response = await apiClient.post(
        '/meal-plans/$planId/entries',
        data: {
          'recipeId': recipeId,
          'mealDate': mealDate,
          'mealType': mealType,
          'servings': servings,
          'notes': notes,
        },
      );
      return handleResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Supprime une entrée d'un plan de repas.
  Future<void> deleteEntry(String entryId) async {
    try {
      await apiClient.delete('/meal-plans/entries/$entryId');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Active un plan de repas.
  Future<void> activatePlan(String planId) async {
    try {
      await apiClient.post('/meal-plans/$planId/activate');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Supprime un plan de repas.
  Future<void> deleteMealPlan(String planId) async {
    try {
      await apiClient.delete('/meal-plans/$planId');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère les options d'échange pour une entrée de plan.
  Future<List<Map<String, dynamic>>> getSwapOptions(
      String entryId, int limit) async {
    try {
      final response = await apiClient.get(
        '/meal-plans/entries/$entryId/swap-options',
        query: {'limit': limit},
      );
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  /// Applique un échange de recette sur une entrée.
  Future<MealPlan> applySwap(String entryId, String newRecipeId) async {
    try {
      final response = await apiClient.post(
        '/meal-plans/entries/$entryId/swap',
        query: {'newRecipeId': newRecipeId},
      );
      return handleResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Définit le mode de génération d'un plan.
  Future<MealPlan> setMode(String planId, String mode) async {
    try {
      final response = await apiClient.put(
        '/meal-plans/$planId/mode',
        query: {'mode': mode},
      );
      return handleResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Génère un plan hebdomadaire avec un mode spécifique.
  Future<MealPlan> generateWeeklyPlanWithMode(
      {required String startDate, String mode = 'STANDARD'}) async {
    try {
      final response = await apiClient.post(
        '/meal-plans/generate',
        query: {'startDate': startDate, 'mode': mode},
      );
      return handleResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

/// Fournisseur du dépôt de plans de repas.
final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepository(ref.watch(apiClientProvider));
});
