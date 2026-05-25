import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_response.dart';
import 'base_repository.dart';

export 'base_repository.dart' show ApiException;

class RecipeRepository extends BaseRepository {
  RecipeRepository(super.apiClient);

  Future<PageResponse<RecipeDetail>> searchRecipes({
    required String query,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/recipes/public/search',
        query: {'q': query, 'page': page, 'size': size},
      );
      return handlePageResponse(response, RecipeDetail.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<RecipeDetail> getRecipeDetail(String recipeId) async {
    try {
      final response = await apiClient.get('/recipes/public/$recipeId');
      return handleResponse(response, RecipeDetail.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<PageResponse<RecipeDetail>> getPublicRecipes({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/recipes/public',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, RecipeDetail.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<PageResponse<RecipeDetail>> getByCuisine(
    String cuisine, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/recipes/public/cuisine/$cuisine',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, RecipeDetail.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<PageResponse<RecipeDetail>> getByMealType(
    String mealType, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/recipes/public/meal/$mealType',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, RecipeDetail.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<bool> favoriteRecipe(String recipeId) async {
    try {
      await apiClient.post('/recipes/$recipeId/favorite');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> unfavoriteRecipe(String recipeId) async {
    try {
      await apiClient.delete('/recipes/$recipeId/favorite');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<PageResponse<RecipeDetail>> getFavoriteRecipes({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/recipes/favorites',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, RecipeDetail.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

class RecipeDetail {
  const RecipeDetail({
    this.id,
    this.name,
    this.description,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.totalTimeMinutes,
    this.servings,
    this.difficulty,
    this.cuisineType,
    this.mealType,
    this.imageUrl,
    this.source,
    this.isPublic,
    this.userId,
    this.ingredients = const [],
    this.steps = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? name;
  final String? description;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? totalTimeMinutes;
  final int? servings;
  final String? difficulty;
  final String? cuisineType;
  final String? mealType;
  final String? imageUrl;
  final String? source;
  final bool? isPublic;
  final String? userId;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final String? createdAt;
  final String? updatedAt;

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      prepTimeMinutes: json['prepTimeMinutes'] as int?,
      cookTimeMinutes: json['cookTimeMinutes'] as int?,
      totalTimeMinutes: json['totalTimeMinutes'] as int?,
      servings: json['servings'] as int?,
      difficulty: json['difficulty'] as String?,
      cuisineType: json['cuisineType'] as String?,
      mealType: json['mealType'] as String?,
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String?,
      isPublic: json['isPublic'] as bool?,
      userId: json['userId'] as String?,
      ingredients: (json['ingredients'] as List?)
              ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      steps: (json['steps'] as List?)
              ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class RecipeIngredient {
  const RecipeIngredient({
    this.id,
    this.name,
    this.quantity,
    this.unit,
    this.notes,
    this.sortOrder,
    this.ingredientId,
  });

  final String? id;
  final String? name;
  final double? quantity;
  final String? unit;
  final String? notes;
  final int? sortOrder;
  final String? ingredientId;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] as String?,
      name: json['name'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
      sortOrder: json['sortOrder'] as int?,
      ingredientId: json['ingredientId'] as String?,
    );
  }
}

class RecipeStep {
  const RecipeStep({
    this.id,
    this.stepNumber,
    this.instruction,
    this.durationMinutes,
  });

  final String? id;
  final int? stepNumber;
  final String? instruction;
  final int? durationMinutes;

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'] as String?,
      stepNumber: json['stepNumber'] as int?,
      instruction: json['instruction'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
    );
  }
}

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(apiClientProvider));
});
