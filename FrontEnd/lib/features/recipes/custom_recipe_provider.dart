import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/mvp_entities.dart';

/// Notifier qui gère la liste des recettes personnalisées.
class CustomRecipesNotifier extends Notifier<List<CustomRecipe>> {
  @override
  List<CustomRecipe> build() => const [];

  /// Ajoute une recette personnalisée à la liste.
  void add(CustomRecipe recipe) {
    state = [...state, recipe];
  }
}

/// Provider Riverpod pour les recettes personnalisées.
final customRecipesProvider =
    NotifierProvider<CustomRecipesNotifier, List<CustomRecipe>>(
      CustomRecipesNotifier.new,
    );
