import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/meal_plan.dart';

class MealPlanRepository extends BaseRepository {
  MealPlanRepository(super.apiClient);

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

  Future<MealPlan> getMealPlan(String id) async {
    try {
      final response = await apiClient.get('/meal-plans/$id');
      return handleResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

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
          if (notes != null) 'notes': notes,
        },
      );
      return handleResponse(response, MealPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await apiClient.delete('/meal-plans/entries/$entryId');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> activatePlan(String planId) async {
    try {
      await apiClient.post('/meal-plans/$planId/activate');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> deleteMealPlan(String planId) async {
    try {
      await apiClient.delete('/meal-plans/$planId');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepository(ref.watch(apiClientProvider));
});
