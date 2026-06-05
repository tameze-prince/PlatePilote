import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/pantry_item.dart';

/// Service pour les opérations liées au garde-manger.
class PantryService {
  PantryService(this.client);

  /// Client API pour les requêtes HTTP.
  final ApiClient client;

  /// Récupère la liste des articles du garde-manger depuis l'API.
  Future<List<PantryItem>> fetchPantryItems() async {
    try {
      final response = await client.get('/pantry/items');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => PantryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Ajoute un article au garde-manger via l'API.
  Future<void> addItem(PantryItem item) async {
    try {
      await client.post('/pantry/items', data: item.toJson());
    } catch (_) {}
  }
}

/// Fournisseur du service de garde-manger.
final pantryServiceProvider = Provider<PantryService>((ref) {
  return PantryService(ref.watch(apiClientProvider));
});
