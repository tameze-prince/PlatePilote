import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/base_repository.dart';
import '../../shared/models/demo_data.dart' as demo;
import '../../shared/models/pantry_item.dart';
import 'pantry_repository.dart';

class PantryListState {
  const PantryListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.useDemoFallback = false,
  });

  final List<PantryItem> items;
  final bool isLoading;
  final String? error;
  final bool useDemoFallback;

  PantryListState copyWith({
    List<PantryItem>? items,
    bool? isLoading,
    String? error,
    bool? useDemoFallback,
    bool clearError = false,
  }) {
    return PantryListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      useDemoFallback: useDemoFallback ?? this.useDemoFallback,
    );
  }
}

class PantryNotifier extends Notifier<PantryListState> {
  @override
  PantryListState build() {
    Future.microtask(() => _loadItems());
    return PantryListState(
      items: _demoItems,
      isLoading: true,
      useDemoFallback: true,
    );
  }

  static final List<PantryItem> _demoItems =
      demo.pantryItems.map((d) => PantryItem(
        id: d.name.hashCode.toString(),
        name: d.name,
        quantity: double.tryParse(d.quantity),
        unit: 'unit',
        category: d.category,
        expirationDate: d.expires,
        isExpired: d.urgent,
      )).toList();

  Future<void> _loadItems() async {
    try {
      final repo = ref.read(pantryRepositoryProvider);
      final page = await repo.listPantryItems(size: 50);
      state = PantryListState(items: page.content, isLoading: false);
    } catch (_) {
      state = PantryListState(items: _demoItems, useDemoFallback: true, isLoading: false);
    }
  }

  Future<void> refresh() => _loadItems();

  Future<void> addItem({
    required String name,
    String? category,
    required double quantity,
    required String unit,
    String? expirationDate,
  }) async {
    try {
      final repo = ref.read(pantryRepositoryProvider);
      final item = await repo.addItem(
        name: name,
        category: category,
        quantity: quantity,
        unit: unit,
        expirationDate: expirationDate,
      );
      state = state.copyWith(items: [...state.items, item]);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> updateItemQuantity(int index, double quantity, String unit) async {
    if (index >= state.items.length) return;
    final item = state.items[index];
    if (item.id.isEmpty) return;

    try {
      final repo = ref.read(pantryRepositoryProvider);
      await repo.consumeItem(item.id, quantity);

      // Refresh to get actual state from backend
      await _loadItems();
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> deleteItem(int index) async {
    if (index >= state.items.length) return;
    final item = state.items[index];
    if (item.id.isEmpty) return;
    try {
      await ref.read(pantryRepositoryProvider).deleteItem(item.id);
      final updated = [...state.items]..removeAt(index);
      state = state.copyWith(items: updated);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }
}

final pantryProvider = NotifierProvider<PantryNotifier, PantryListState>(
  PantryNotifier.new,
);
