import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/base_repository.dart';
import '../../shared/models/demo_data.dart' as demo;
import '../../shared/models/pantry_item.dart';
import 'pantry_repository.dart';

/// État de la liste du garde-manger.
/// Contient les articles, l'état de chargement et les erreurs.
class PantryListState {
  const PantryListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.useDemoFallback = false,
  });

  /// Liste des articles du garde-manger.
  final List<PantryItem> items;

  /// Indique si le chargement est en cours.
  final bool isLoading;

  /// Message d'erreur éventuel.
  final String? error;

  /// Utilise les données de démonstration en fallback.
  final bool useDemoFallback;

  /// Crée une copie avec des champs mis à jour.
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

/// Notifier qui gère l'état du garde-manger.
/// Charge, ajoute, modifie et supprime des articles.
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

  /// Articles de démonstration utilisés en fallback.
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

  /// Charge les articles du garde-manger depuis l'API.
  Future<void> _loadItems() async {
    try {
      final repo = ref.read(pantryRepositoryProvider);
      final page = await repo.listPantryItems(size: 50);
      state = PantryListState(items: page.content, isLoading: false);
    } catch (_) {
      state = PantryListState(items: _demoItems, useDemoFallback: true, isLoading: false);
    }
  }

  /// Recharge les articles du garde-manger.
  Future<void> refresh() => _loadItems();

  /// Ajoute un article au garde-manger.
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

  /// Met à jour la quantité d'un article (consommation).
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

  /// Supprime un article du garde-manger.
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

/// Fournisseur de l'état du garde-manger.
final pantryProvider = NotifierProvider<PantryNotifier, PantryListState>(
  PantryNotifier.new,
);
