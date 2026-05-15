import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';
import '../../shared/models/demo_data.dart';

class GroceryListState {
  const GroceryListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<GroceryItem> items;
  final bool isLoading;
  final String? error;
}

class GroceryNotifier extends Notifier<GroceryListState> {
  static const _key = 'grocery.list';

  @override
  GroceryListState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    if (stored != null) {
      final list = (json.decode(stored) as List)
          .map((e) => _groceryItemFromJson(e as Map<String, dynamic>))
          .toList();
      return GroceryListState(items: list);
    }
    return const GroceryListState(items: groceryItems);
  }

  Future<void> toggleItem(int index) async {
    final item = state.items[index];
    final updated = GroceryItem(
      name: item.name,
      quantity: item.quantity,
      price: item.price,
      category: item.category,
      checked: !item.checked,
    );
    final items = [...state.items];
    items[index] = updated;
    state = GroceryListState(items: items);
    await _persist();
  }

  Future<void> addItem(GroceryItem item) async {
    state = GroceryListState(items: [...state.items, item]);
    await _persist();
  }

  Future<void> removeItem(int index) async {
    final items = [...state.items]..removeAt(index);
    state = GroceryListState(items: items);
    await _persist();
  }

  Future<void> _persist() async {
    final encoded = state.items.map(_groceryItemToJson).toList();
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, jsonEncode(encoded));
  }

  Map<String, dynamic> _groceryItemToJson(GroceryItem item) => {
    'name': item.name,
    'quantity': item.quantity,
    'price': item.price,
    'category': item.category,
    'checked': item.checked,
  };

  GroceryItem _groceryItemFromJson(Map<String, dynamic> json) {
    return GroceryItem(
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      price: json['price'] as String,
      category: json['category'] as String,
      checked: json['checked'] as bool? ?? false,
    );
  }
}

final groceryProvider = NotifierProvider<GroceryNotifier, GroceryListState>(
  GroceryNotifier.new,
);
