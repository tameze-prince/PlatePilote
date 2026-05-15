import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/mvp_entities.dart';

class CustomRecipesNotifier extends Notifier<List<CustomRecipe>> {
  @override
  List<CustomRecipe> build() => const [];

  void add(CustomRecipe recipe) {
    state = [...state, recipe];
  }
}

final customRecipesProvider =
    NotifierProvider<CustomRecipesNotifier, List<CustomRecipe>>(
      CustomRecipesNotifier.new,
    );
