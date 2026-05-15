import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';
import '../../shared/models/demo_data.dart';

class PantryListState {
  const PantryListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<PantryItem> items;
  final bool isLoading;
  final String? error;

  PantryListState copyWith({
    List<PantryItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return PantryListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PantryNotifier extends Notifier<PantryListState> {
  static const _key = 'pantry.list';

  @override
  PantryListState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    if (stored != null) {
      final list = (json.decode(stored) as List)
          .map((e) => _pantryItemFromJson(e as Map<String, dynamic>))
          .toList();
      return PantryListState(items: list);
    }
    return const PantryListState(items: pantryItems);
  }

  Future<void> addItem(PantryItem item) async {
    state = PantryListState(items: [...state.items, item]);
    await _persist();
  }

  Future<void> removeItem(int index) async {
    final items = [...state.items]..removeAt(index);
    state = PantryListState(items: items);
    await _persist();
  }

  PantryListState filterByCategory(String category) {
    if (category.isEmpty) return state;
    final filtered = state.items
        .where((item) => item.category.toLowerCase() == category.toLowerCase())
        .toList();
    return PantryListState(items: filtered);
  }

  Future<void> _persist() async {
    final encoded = state.items.map(_pantryItemToJson).toList();
    await ref.read(sharedPreferencesProvider).setString(_key, jsonEncode(encoded));
  }

  Map<String, dynamic> _pantryItemToJson(PantryItem item) => {
    'name': item.name,
    'quantity': item.quantity,
    'expires': item.expires,
    'category': item.category,
    'iconCodePoint': item.icon.codePoint,
    'urgent': item.urgent,
  };

  PantryItem _pantryItemFromJson(Map<String, dynamic> json) {
    return PantryItem(
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      expires: json['expires'] as String,
      category: json['category'] as String,
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      urgent: json['urgent'] as bool,
    );
  }
}

final pantryProvider = NotifierProvider<PantryNotifier, PantryListState>(
  PantryNotifier.new,
);
