import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/demo_data.dart';

/// Service pour les opérations liées aux courses.
/// (Non utilisé actuellement, remplacé par [GroceryRepository]).
class GroceryService {
  GroceryService(this.client);

  /// Client API pour les requêtes HTTP.
  final ApiClient client;

  /// Récupère la liste de courses.
  Future<List<GroceryItem>> fetchGroceryList() async {
    // TODO: Replace with actual API call using client
    return groceryItems;
  }
}

/// Fournisseur du service de courses.
final groceryServiceProvider = Provider<GroceryService>((ref) {
  return GroceryService(ref.watch(apiClientProvider));
});
