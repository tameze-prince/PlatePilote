import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/base_repository.dart';
import '../../shared/models/demo_data.dart' as demo;
import '../../shared/models/grocery_list.dart';
import 'grocery_repository.dart';

class GroceryListState {
  const GroceryListState({
    this.currentList,
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.useDemoFallback = false,
  });

  final GroceryList? currentList;
  final List<GroceryItem> items;
  final bool isLoading;
  final String? error;
  final bool useDemoFallback;

  GroceryListState copyWith({
    GroceryList? currentList,
    List<GroceryItem>? items,
    bool? isLoading,
    String? error,
    bool? useDemoFallback,
    bool clearError = false,
  }) {
    return GroceryListState(
      currentList: currentList ?? this.currentList,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      useDemoFallback: useDemoFallback ?? this.useDemoFallback,
    );
  }
}

class GroceryNotifier extends Notifier<GroceryListState> {
  @override
  GroceryListState build() {
    Future.microtask(() => _loadCurrentList());
    return GroceryListState(
      items: _demoItems,
      isLoading: true,
      useDemoFallback: true,
    );
  }

  static final List<GroceryItem> _demoItems =
      demo.groceryItems.map((d) => GroceryItem(
        name: d.name,
        quantity: double.tryParse(d.quantity.replaceAll(RegExp(r'[^\d.]'), '')),
        unit: 'unit',
        category: d.category,
        estimatedPrice: double.tryParse(d.price.replaceAll(RegExp(r'[^\d.]'), '')),
        checked: d.checked,
      )).toList();

  Future<void> _loadCurrentList() async {
    try {
      final repo = ref.read(groceryRepositoryProvider);
      final page = await repo.listGroceryLists(size: 1);
      if (page.content.isNotEmpty) {
        final list = page.content.first;
        state = GroceryListState(
          currentList: list,
          items: list.items,
        );
      }
    } on ApiException {
      state = GroceryListState(items: _demoItems, useDemoFallback: true);
    }
  }

  Future<void> generateFromMealPlan(String mealPlanId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(groceryRepositoryProvider);
      final list = await repo.generateFromMealPlan(mealPlanId);
      state = GroceryListState(currentList: list, items: list.items);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> toggleItem(int index) async {
    final items = [...state.items];
    if (index >= items.length) return;
    final item = items[index];
    if (item.id == null) return;
    items[index] = item.copyWith(checked: !item.checked);
    state = state.copyWith(items: items);
    try {
      await ref.read(groceryRepositoryProvider).toggleItem(item.id!);
    } on ApiException {
      items[index] = item;
      state = state.copyWith(items: items);
    }
  }

  Future<void> addItem({
    required String name,
    String? category,
    required double quantity,
    required String unit,
    double? estimatedPrice,
    String? notes,
  }) async {
    final listId = state.currentList?.id;
    if (listId != null) {
      try {
        final repo = ref.read(groceryRepositoryProvider);
        final list = await repo.addItem(
          listId,
          name: name,
          category: category,
          quantity: quantity,
          unit: unit,
          estimatedPrice: estimatedPrice,
          notes: notes,
        );
        state = GroceryListState(currentList: list, items: list.items);
        return;
      } on ApiException catch (e) {
        state = state.copyWith(error: e.message);
        return;
      }
    }
    final newItem = GroceryItem(
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      estimatedPrice: estimatedPrice,
      notes: notes,
    );
    state = state.copyWith(items: [...state.items, newItem]);
  }

  Future<void> refresh() => _loadCurrentList();
}

final groceryProvider = NotifierProvider<GroceryNotifier, GroceryListState>(
  GroceryNotifier.new,
);
