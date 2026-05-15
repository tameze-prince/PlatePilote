import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/demo_data.dart';
import 'grocery_provider.dart';

final groceryRepositoryProvider = Provider<GroceryRepository>((ref) {
  return GroceryRepository(ref);
});

class GroceryRepository {
  const GroceryRepository(this._ref);

  final Ref _ref;

  List<GroceryItem> read() => _ref.read(groceryProvider).items;
  Future<void> add(GroceryItem item) =>
      _ref.read(groceryProvider.notifier).addItem(item);
}
