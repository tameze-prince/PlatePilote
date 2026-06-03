import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/demo_data.dart';

/// Service pour les opérations liées au garde-manger.
/// (Non utilisé actuellement, remplacé par [PantryRepository]).
class PantryService {
  PantryService(this.client);

  /// Client API pour les requêtes HTTP.
  final ApiClient client;

  /// Récupère la liste des articles du garde-manger.
  Future<List<PantryItem>> fetchPantryItems() async {
    // TODO: Replace with actual API call using client
    return pantryItems;
  }

  /// Ajoute un article au garde-manger.
  Future<void> addItem(PantryItem item) async {
    // TODO: Replace with actual API call using client
  }
}

/// Fournisseur du service de garde-manger.
final pantryServiceProvider = Provider<PantryService>((ref) {
  return PantryService(ref.watch(apiClientProvider));
});
