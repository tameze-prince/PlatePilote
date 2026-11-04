import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_response.dart';
import 'base_repository.dart';

export 'base_repository.dart' show ApiException;

/// Repository des recettes (recherche, détail, favoris).
class RecipeRepository extends BaseRepository {
  RecipeRepository(super.apiClient);

  /// Recherche des recettes publiques par mot-clé.
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

  /// Récupère le détail d'une recette publique par son identifiant.
  Future<RecipeDetail> getRecipeDetail(String recipeId) async {
    try {
      final response = await apiClient.get('/recipes/public/$recipeId');
      return handleResponse(response, RecipeDetail.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère les recettes publiques avec pagination.
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

  /// Récupère les recettes par type de cuisine.
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

  /// Récupère les recettes par type de repas.
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

  /// Ajoute une recette aux favoris.
  Future<bool> favoriteRecipe(String recipeId) async {
    try {
      await apiClient.post('/recipes/$recipeId/favorite');
      return true;
    } on DioException {
      return false;
    }
  }

  /// Retire une recette des favoris.
  Future<bool> unfavoriteRecipe(String recipeId) async {
    try {
      await apiClient.delete('/recipes/$recipeId/favorite');
      return true;
    } on DioException {
      return false;
    }
  }

  /// Récupère la liste des recettes favorites de l'utilisateur.
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

/// Détail complet d'une recette (informations, ingrédients, étapes).
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
    this.caloriesPerServing,
    this.proteinPerServing,
    this.carbsPerServing,
    this.fatPerServing,
    this.fiberPerServing,
    this.containsGluten,
    this.containsLactose,
    this.containsNuts,
    this.containsSoy,
    this.containsEggs,
    this.containsFish,
    this.containsShellfish,
    this.allergenSource,
    this.nutritionSource,
    this.verified,
    this.verificationStatus,
    this.confidenceScore,
    this.ingredients = const [],
    this.steps = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Identifiant de la recette.
  final String? id;

  /// Nom de la recette.
  final String? name;

  /// Description textuelle.
  final String? description;

  /// Temps de préparation en minutes.
  final int? prepTimeMinutes;

  /// Temps de cuisson en minutes.
  final int? cookTimeMinutes;

  /// Temps total en minutes.
  final int? totalTimeMinutes;

  /// Nombre de portions.
  final int? servings;

  /// Niveau de difficulté.
  final String? difficulty;

  /// Type de cuisine.
  final String? cuisineType;

  /// Type de repas (petit-déjeuner, déjeuner, dîner, etc.).
  final String? mealType;

  /// URL de l'image.
  final String? imageUrl;

  /// Source de la recette.
  final String? source;

  /// Indique si la recette est publique.
  final bool? isPublic;

  /// Identifiant du créateur.
  final String? userId;

  /// Nutrition values per serving.
  final int? caloriesPerServing;
  final double? proteinPerServing;
  final double? carbsPerServing;
  final double? fatPerServing;
  final double? fiberPerServing;

  /// Nullable allergen flags; null means the data is unknown.
  final bool? containsGluten;
  final bool? containsLactose;
  final bool? containsNuts;
  final bool? containsSoy;
  final bool? containsEggs;
  final bool? containsFish;
  final bool? containsShellfish;
  final String? allergenSource;
  final String? nutritionSource;
  final bool? verified;
  final String? verificationStatus;
  final double? confidenceScore;

  /// Liste des ingrédients.
  final List<RecipeIngredient> ingredients;

  /// Liste des étapes de préparation.
  final List<RecipeStep> steps;

  /// Date de création.
  final String? createdAt;

  /// Date de dernière modification.
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
      caloriesPerServing: (json['caloriesPerServing'] as num?)?.round(),
      proteinPerServing: (json['proteinPerServing'] as num?)?.toDouble(),
      carbsPerServing: (json['carbsPerServing'] as num?)?.toDouble(),
      fatPerServing: (json['fatPerServing'] as num?)?.toDouble(),
      fiberPerServing: (json['fiberPerServing'] as num?)?.toDouble(),
      containsGluten: json['containsGluten'] as bool?,
      containsLactose: json['containsLactose'] as bool?,
      containsNuts: json['containsNuts'] as bool?,
      containsSoy: json['containsSoy'] as bool?,
      containsEggs: json['containsEggs'] as bool?,
      containsFish: json['containsFish'] as bool?,
      containsShellfish: json['containsShellfish'] as bool?,
      allergenSource: json['allergenSource'] as String?,
      nutritionSource: json['nutritionSource'] as String?,
      verified: json['verified'] as bool?,
      verificationStatus: json['verificationStatus'] as String?,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      ingredients:
          (json['ingredients'] as List?)
              ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      steps:
          (json['steps'] as List?)
              ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

/// Ingrédient d'une recette avec quantité, unité et ordre.
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

  /// Identifiant de l'ingrédient dans la recette.
  final String? id;

  /// Nom de l'ingrédient.
  final String? name;

  /// Quantité nécessaire.
  final double? quantity;

  /// Unité de mesure.
  final String? unit;

  /// Notes optionnelles sur l'ingrédient.
  final String? notes;

  /// Ordre d'affichage dans la liste.
  final int? sortOrder;

  /// Identifiant de l'ingrédient de référence.
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

/// Étape de préparation d'une recette.
class RecipeStep {
  const RecipeStep({
    this.id,
    this.stepNumber,
    this.instruction,
    this.durationMinutes,
  });

  /// Identifiant de l'étape.
  final String? id;

  /// Numéro d'ordre de l'étape.
  final int? stepNumber;

  /// Instruction textuelle.
  final String? instruction;

  /// Durée optionnelle en minutes.
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

/// Provider Riverpod pour [RecipeRepository].
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(apiClientProvider));
});
