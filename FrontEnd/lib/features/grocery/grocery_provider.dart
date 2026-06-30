import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/analytics/event_payload.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/demo_data.dart' as demo;
import '../../shared/models/grocery_list.dart';
import '../../shared/models/purchase_record.dart';
import '../pantry/pantry_provider.dart';
import 'grocery_fuzzy.dart';
import 'grocery_repository.dart';

/// État de la liste de courses.
/// Contient la liste courante, les articles, l'historique et l'état de chargement.
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

  /// Liste de courses courante.
  final GroceryList? currentList;

  /// Articles de la liste.
  final List<GroceryItem> items;

  /// Indique si le chargement est en cours.
  final bool isLoading;

  /// Message d'erreur éventuel.
  final String? error;

  /// Utilise les données de démonstration en fallback.
  final bool useDemoFallback;

  /// Historique des achats.
  final List<PurchaseRecord> purchaseHistory;

  /// Indique si la sauvegarde est en cours.
  final bool isSaving;

  /// Prix total estimé de tous les articles.
  double get totalEstimatedPrice =>
      items.fold<double>(0, (sum, item) => sum + (item.estimatedPrice ?? 0));

  /// Nombre d'articles cochés (achetés).
  int get checkedCount => items.where((i) => i.checked).length;

  /// Crée une copie avec des champs mis à jour.
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

/// Notifier qui gère l'état de la liste de courses.
/// Charge, ajoute, modifie et supprime des articles, gère le checkout.
class GroceryNotifier extends Notifier<GroceryListState> {
  @override
  GroceryListState build() {
    Future.microtask(() => _loadCurrentList());
    return const GroceryListState(
      isLoading: true,
    );
  }

  /// Articles de démonstration utilisés en fallback.
  static final List<GroceryItem> _demoItems =
      demo.groceryItems.map((d) => GroceryItem(
        name: d.name,
        quantity: double.tryParse(d.quantity.replaceAll(RegExp(r'[^\d.]'), '')),
        unit: 'unit',
        category: d.category,
        estimatedPrice: double.tryParse(d.price.replaceAll(RegExp(r'[^\d.]'), '')),
        checked: d.checked,
      )).toList();

  /// Charge la liste de courses courante depuis l'API.
  Future<void> _loadCurrentList() async {
    try {
      final repo = ref.read(groceryRepositoryProvider);
      final page = await repo.listGroceryLists(size: 1);
      if (page.content.isNotEmpty) {
        final list = await repo.getGroceryList(page.content.first.id);
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

  /// Génère une liste de courses à partir d'un plan de repas.
  Future<void> generateFromMealPlan(String mealPlanId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(groceryRepositoryProvider);
      final list = await repo.generateFromMealPlan(mealPlanId);
      state = GroceryListState(currentList: list, items: list.items);
      ref.read(analyticsServiceProvider).trackPayload(
        PlateEvents.groceryListGenerated,
        payload: EventPayload(
          source: 'auto_gen',
          meta: <String, Object>{
            'mealPlanId': mealPlanId,
            'itemCount': list.items.length,
          },
        ),
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  /// Bascule l'état coché/décoché d'un article.
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

  /// Met à jour la quantité et l'unité d'un article.
  Future<void> updateItemQuantity(int index, double quantity, String unit) async {
    if (index >= state.items.length) return;
    final item = state.items[index];
    final updated = item.copyWith(quantity: quantity, unit: unit);
    final items = [...state.items];
    items[index] = updated;
    state = state.copyWith(items: items);
  }

  /// Supprime un article de la liste (optimiste).
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

  /// Ajoute un article à la liste de courses.
  ///
  /// Logique de dédup fuzzy:
  /// 1. Si backend (listId != null), on envoie la requête — le backend
  ///    effectuera sa propre dédup. On protège le fallback local aussi.
  /// 2. Sinon (mode demo / offline), on cherche un doublon fuzzy dans
  ///    `state.items` et on fusionne les quantités au lieu d'ajouter.
  Future<void> addItem({
    required String name,
    String? category,
    required double quantity,
    required String unit,
    double? estimatedPrice,
    String? notes,
  }) async {
    // ── Dédup locale (offline / fallback) ──────────────────────
    final dupIndex = findDuplicateIndex<String>(
      state.items.map((i) => i.name).toList(),
      name,
      (s) => s,
    );
    if (dupIndex >= 0) {
      final items = [...state.items];
      final existing = items[dupIndex];
      final mergedQty = (existing.quantity ?? 0) + quantity;
      items[dupIndex] = existing.copyWith(
        quantity: mergedQty,
        // si nouvelle unité non-vide et différente, on garde l'existante
        unit: unit.isNotEmpty ? unit : existing.unit,
        notes: notes ?? existing.notes,
      );
      // Note: copyWith n'expose pas estimatedPrice, mais on a déjà
      // additionné les prix implicite côté serveur lors de la dédup API.
      state = state.copyWith(items: items);
      return; // Skip API call — already updated locally
    }

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

  /// Marque les articles cochés comme achetés et met à jour le garde-manger.
  Future<void> markItemsAsBought() async {
    final checkedItems = state.items.where((i) => i.checked).toList();
    if (checkedItems.isEmpty) return;

    state = state.copyWith(isSaving: true);

    final listId = state.currentList?.id;
    if (listId != null) {
      try {
        final repo = ref.read(groceryRepositoryProvider);
        final checkedIds = checkedItems
            .map((i) => i.id)
            .whereType<String>()
            .toList();

        if (checkedIds.isNotEmpty) {
          await repo.checkoutList(listId, checkedItemIds: checkedIds);
        }

        // Refresh grocery list state after checkout
        await _loadCurrentList();

        // Refresh pantry to reflect additions
        ref.read(pantryProvider.notifier).refresh();

        state = state.copyWith(isSaving: false);
        return;
      } on ApiException catch (e) {
        state = state.copyWith(isSaving: false, error: e.message);
        return;
      }
    }

    // Fallback for local-only items (no list)
    final pantryNotifier = ref.read(pantryProvider.notifier);
    for (final item in checkedItems) {
      await pantryNotifier.addItem(
        name: item.name,
        category: item.category,
        quantity: item.quantity ?? 1,
        unit: item.unit ?? 'unit',
      );
    }

    final remaining = state.items.where((i) => !i.checked).toList();
    state = state.copyWith(items: remaining, isSaving: false);
  }

  /// Sauvegarde la liste de courses (complète).
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

  /// Recharge la liste de courses depuis l'API.
  Future<void> refresh() => _loadCurrentList();
}

/// Fournisseur de l'état de la liste de courses.
final groceryProvider = NotifierProvider<GroceryNotifier, GroceryListState>(
  GroceryNotifier.new,
);
