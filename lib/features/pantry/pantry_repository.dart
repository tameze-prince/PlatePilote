import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/demo_data.dart';
import 'pantry_provider.dart';

final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  return PantryRepository(ref);
});

class PantryRepository {
  const PantryRepository(this._ref);

  final Ref _ref;

  List<PantryItem> read() => _ref.read(pantryProvider).items;
  Future<void> add(PantryItem item) =>
      _ref.read(pantryProvider.notifier).addItem(item);
}
