import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/pantry_item.dart';

/// Dépôt du garde-manger.
/// Communique avec l'API pour gérer les articles du garde-manger.
class PantryRepository extends BaseRepository {
  PantryRepository(super.apiClient);

  /// Récupère la liste paginée des articles du garde-manger.
  Future<PageResponse<PantryItem>> listPantryItems({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/pantry',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, PantryItem.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère les articles d'une catégorie donnée.
  Future<List<PantryItem>> getByCategory(String category) async {
    try {
      final response = await apiClient.get('/pantry/category/$category');
      return handleListResponse(response, PantryItem.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère les articles qui expirent dans un nombre de jours donné.
  Future<List<PantryItem>> getExpiring({int days = 7}) async {
    try {
      final response = await apiClient.get(
        '/pantry/expiring',
        query: {'days': days},
      );
      return handleListResponse(response, PantryItem.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Recherche des articles dans le garde-manger par nom.
  Future<List<PantryItem>> search(String query) async {
    try {
      final response = await apiClient.get(
        '/pantry/search',
        query: {'q': query},
      );
      return handleListResponse(response, PantryItem.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Ajoute un article au garde-manger.
  Future<PantryItem> addItem({
    required String name,
    String? category,
    required double quantity,
    required String unit,
    String? expirationDate,
  }) async {
    try {
      final response = await apiClient.post('/pantry', data: {
        'name': name,
        if (category != null) 'category': category,
        'quantity': quantity,
        'unit': unit,
        if (expirationDate != null) 'expirationDate': expirationDate,
      });
      return handleResponse(response, PantryItem.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Met à jour un article du garde-manger.
  Future<PantryItem> updateItem(
    String itemId, {
    required String name,
    String? category,
    required double quantity,
    required String unit,
    String? expirationDate,
  }) async {
    try {
      final response = await apiClient.put('/pantry/$itemId', data: {
        'name': name,
        if (category != null) 'category': category,
        'quantity': quantity,
        'unit': unit,
        if (expirationDate != null) 'expirationDate': expirationDate,
      });
      return handleResponse(response, PantryItem.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Supprime un article du garde-manger.
  Future<void> deleteItem(String itemId) async {
    try {
      await apiClient.delete('/pantry/$itemId');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Consomme une quantité d'un article (décrémente le stock).
  Future<void> consumeItem(String itemId, double amount) async {
    try {
      await apiClient.patch(
        '/pantry/$itemId/consume',
        query: {'amount': amount},
      );
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

/// Fournisseur du dépôt du garde-manger.
final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  return PantryRepository(ref.watch(apiClientProvider));
});
