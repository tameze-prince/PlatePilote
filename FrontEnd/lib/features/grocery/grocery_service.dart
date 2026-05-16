import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/demo_data.dart';

class GroceryService {
  GroceryService(this.client);

  final ApiClient client;

  Future<List<GroceryItem>> fetchGroceryList() async {
    // TODO: Replace with actual API call using client
    return groceryItems;
  }
}

final groceryServiceProvider = Provider<GroceryService>((ref) {
  return GroceryService(ref.watch(apiClientProvider));
});
