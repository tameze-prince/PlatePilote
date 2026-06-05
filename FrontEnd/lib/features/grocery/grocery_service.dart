import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/grocery_list.dart';

/// Service pour les opérations liées aux courses.
class GroceryService {
  GroceryService(this.client);

  /// Client API pour les requêtes HTTP.
  final ApiClient client;

  /// Récupère la liste de courses depuis l'API.
  Future<List<GroceryItem>> fetchGroceryList() async {
    try {
      final response = await client.get('/grocery-lists/current');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => GroceryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

/// Fournisseur du service de courses.
final groceryServiceProvider = Provider<GroceryService>((ref) {
  return GroceryService(ref.watch(apiClientProvider));
});
