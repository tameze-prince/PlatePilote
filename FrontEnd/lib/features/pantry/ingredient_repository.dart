import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/ingredient.dart';

class IngredientRepository extends BaseRepository {
  IngredientRepository(super.apiClient);

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

  Future<Ingredient> getById(String id) async {
    try {
      final response = await apiClient.get('/ingredients/$id');
      return handleResponse(response, Ingredient.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  return IngredientRepository(ref.watch(apiClientProvider));
});
