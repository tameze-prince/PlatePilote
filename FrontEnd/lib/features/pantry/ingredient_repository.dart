import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/ingredient.dart';

/// Dépôt des ingrédients.
/// Permet de rechercher et récupérer des ingrédients depuis l'API.
class IngredientRepository extends BaseRepository {
  IngredientRepository(super.apiClient);

  /// Recherche des ingrédients par nom.
  Future<List<Ingredient>> search(String query) async {
    try {
      final response = await apiClient.get(
        '/ingredients/search',
        query: {'q': query, 'size': 20},
      );
      final page = handlePageResponse(response, Ingredient.fromJson);
      return page.content;
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère les ingrédients d'une catégorie donnée.
  Future<List<Ingredient>> getByCategory(String category) async {
    try {
      final response = await apiClient.get(
        '/ingredients/category/$category',
        query: {'size': 50},
      );
      final page = handlePageResponse(response, Ingredient.fromJson);
      return page.content;
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère un ingrédient par son identifiant.
  Future<Ingredient> getById(String id) async {
    try {
      final response = await apiClient.get('/ingredients/$id');
      return handleResponse(response, Ingredient.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

/// Fournisseur du dépôt d'ingrédients.
final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  return IngredientRepository(ref.watch(apiClientProvider));
});
