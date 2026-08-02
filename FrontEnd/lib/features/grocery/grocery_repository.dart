import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/grocery_list.dart';
import '../../shared/models/purchase_record.dart';

/// Dépôt des listes de courses.
/// Communique avec l'API pour gérer les listes et leurs articles.
class GroceryRepository extends BaseRepository {
  GroceryRepository(super.apiClient);

  /// Récupère la liste paginée des listes de courses.
  Future<PageResponse<GroceryList>> listGroceryLists({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/grocery-lists',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, GroceryList.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère une liste de courses par son identifiant.
  Future<GroceryList> getGroceryList(String listId) async {
    try {
      final response = await apiClient.get('/grocery-lists/$listId');
      return handleResponse(response, GroceryList.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Génère une liste de courses à partir d'un plan de repas.
  Future<GroceryList> generateFromMealPlan(String mealPlanId) async {
    try {
      final response = await apiClient.post(
        '/grocery-lists/generate',
        query: {'mealPlanId': mealPlanId},
      );
      return handleResponse(response, GroceryList.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Crée une nouvelle liste de courses.
  Future<GroceryList> createGroceryList(String name) async {
    try {
      final response = await apiClient.post(
        '/grocery-lists',
        data: {'name': name},
      );
      return handleResponse(response, GroceryList.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Ajoute un article à une liste de courses.
  Future<GroceryList> addItem(
    String listId, {
    required String name,
    String? category,
    required double quantity,
    required String unit,
    double? estimatedPrice,
    String? notes,
    int sortOrder = 0,
  }) async {
    try {
      final response = await apiClient.post(
        '/grocery-lists/$listId/items',
        data: {
          'name': name,
          if (category != null) 'category': category,
          'quantity': quantity,
          'unit': unit,
          if (estimatedPrice != null) 'estimatedPrice': estimatedPrice,
          if (notes != null) 'notes': notes,
          'sortOrder': sortOrder,
        },
      );
      return handleResponse(response, GroceryList.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Bascule l'état coché/décoché d'un article.
  Future<void> toggleItem(String itemId) async {
    try {
      await apiClient.patch('/grocery-lists/items/$itemId/toggle');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Supprime un article d'une liste de courses.
  Future<void> removeItem(String itemId) async {
    try {
      await apiClient.delete('/grocery-lists/items/$itemId');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Marque une liste de courses comme complétée.
  Future<void> completeList(String listId) async {
    try {
      await apiClient.patch('/grocery-lists/$listId/complete');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Supprime une liste de courses.
  Future<void> deleteGroceryList(String listId) async {
    try {
      await apiClient.delete('/grocery-lists/$listId');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Valide le checkout d'une liste : enregistre les articles achetés.
  Future<void> checkoutList(
    String listId, {
    required List<String> checkedItemIds,
    Map<String, double>? actualPrices,
  }) async {
    try {
      final checkedUuids = checkedItemIds;
      await apiClient.post(
        '/grocery-lists/$listId/checkout',
        data: {
          'checkedItemIds': checkedUuids,
          if (actualPrices != null) 'actualPrices': actualPrices,
        },
      );
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère l'historique des achats de façon paginée.
  Future<PageResponse<PurchaseRecord>> getPurchaseHistory({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/grocery-lists/history',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, PurchaseRecord.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

/// Fournisseur du dépôt de listes de courses.
final groceryRepositoryProvider = Provider<GroceryRepository>((ref) {
  return GroceryRepository(ref.watch(apiClientProvider));
});
