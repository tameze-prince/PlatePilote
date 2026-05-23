import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/base_repository.dart';
import '../../shared/models/demo_data.dart' as demo;
import '../../shared/models/grocery_list.dart';
import '../../shared/models/purchase_record.dart';
import '../pantry/pantry_provider.dart';
import 'grocery_repository.dart';

class GroceryListState {
  const GroceryListState({
    this.currentList,
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.useDemoFallback = false,
    this.purchaseHistory = const [],
    this.isSaving = false,
  });

  final GroceryList? currentList;
  final List<GroceryItem> items;
  final bool isLoading;
  final String? error;
  final bool useDemoFallback;
  final List<PurchaseRecord> purchaseHistory;
  final bool isSaving;

  double get totalEstimatedPrice =>
      items.fold<double>(0, (sum, item) => sum + (item.estimatedPrice ?? 0));

  int get checkedCount => items.where((i) => i.checked).length;

  GroceryListState copyWith({
    GroceryList? currentList,
    List<GroceryItem>? items,
    bool? isLoading,
    String? error,
    bool? useDemoFallback,
    List<PurchaseRecord>? purchaseHistory,
    bool? isSaving,
    bool clearError = false,
  }) {
    return GroceryListState(
      currentList: currentList ?? this.currentList,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      useDemoFallback: useDemoFallback ?? this.useDemoFallback,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class GroceryNotifier extends Notifier<GroceryListState> {
  @override
  GroceryListState build() {
    Future.microtask(() => _loadCurrentList());
    return const GroceryListState(
      isLoading: true,
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
        return;
      }
      state = const GroceryListState(useDemoFallback: true);
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

  Future<void> updateItemQuantity(int index, double quantity, String unit) async {
    if (index >= state.items.length) return;
    final item = state.items[index];
    final updated = item.copyWith(quantity: quantity, unit: unit);
    final items = [...state.items];
    items[index] = updated;
    state = state.copyWith(items: items);
  }

  Future<void> removeItem(int index) async {
    if (index >= state.items.length) return;
    final item = state.items[index];
    final items = [...state.items]..removeAt(index);
    state = state.copyWith(items: items);
    if (item.id != null) {
      try {
        await ref.read(groceryRepositoryProvider).removeItem(item.id!);
      } on ApiException {
        // ignore API errors for optimistic removal
      }
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

  Future<void> markItemsAsBought() async {
    final checkedItems = state.items.where((i) => i.checked).toList();
    if (checkedItems.isEmpty) return;

    final pantryNotifier = ref.read(pantryProvider.notifier);
    for (final item in checkedItems) {
      await pantryNotifier.addItem(
        name: item.name,
        category: item.category,
        quantity: item.quantity ?? 1,
        unit: item.unit ?? 'unit',
      );
    }

    final total = checkedItems.fold<double>(
      0, (sum, item) => sum + (item.estimatedPrice ?? 0),
    );

    final record = PurchaseRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemNames: checkedItems.map((i) => i.name).toList(),
      totalPrice: total,
      boughtDate: DateTime.now(),
    );

    final remaining = state.items.where((i) => !i.checked).toList();
    state = state.copyWith(
      items: remaining,
      purchaseHistory: [...state.purchaseHistory, record],
    );
  }

  Future<void> saveList() async {
    state = state.copyWith(isSaving: true);
    final listId = state.currentList?.id;
    if (listId != null) {
      try {
        final repo = ref.read(groceryRepositoryProvider);
        await repo.completeList(listId);
      } on ApiException {
        // ignore save errors
      }
    }
    state = state.copyWith(isSaving: false);
  }

  Future<void> refresh() => _loadCurrentList();
}

final groceryProvider = NotifierProvider<GroceryNotifier, GroceryListState>(
  GroceryNotifier.new,
);
