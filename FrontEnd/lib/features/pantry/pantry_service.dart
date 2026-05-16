import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/demo_data.dart';

class PantryService {
  PantryService(this.client);

  final ApiClient client;

  Future<List<PantryItem>> fetchPantryItems() async {
    // TODO: Replace with actual API call using client
    return pantryItems;
  }

  Future<void> addItem(PantryItem item) async {
    // TODO: Replace with actual API call using client
  }
}

final pantryServiceProvider = Provider<PantryService>((ref) {
  return PantryService(ref.watch(apiClientProvider));
});
