import '../../shared/models/ingredient.dart';

class SearchUtils {
  const SearchUtils._();

  static List<Ingredient> sortIngredients(
    Iterable<Ingredient> ingredients,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    final sorted = ingredients.toList();
    sorted.sort((a, b) {
      final aScore = _score(a, normalizedQuery);
      final bScore = _score(b, normalizedQuery);
      final scoreCompare = bScore.compareTo(aScore);
      if (scoreCompare != 0) return scoreCompare;

      final popularityCompare = b.popularityScore.compareTo(a.popularityScore);
      if (popularityCompare != 0) return popularityCompare;

      return a.canonicalName.toLowerCase().compareTo(
        b.canonicalName.toLowerCase(),
      );
    });
    return sorted;
  }

  static List<String> suggestionsFor(
    String query,
    Iterable<Ingredient> ingredients,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.length < 2) return const [];

    final queryHead = normalizedQuery.substring(0, 1);
    return ingredients
        .where((ingredient) {
          final name = ingredient.canonicalName.toLowerCase();
          return name.startsWith(queryHead) || name.contains(queryHead);
        })
        .map((ingredient) => ingredient.canonicalName)
        .toSet()
        .take(3)
        .toList();
  }

  static int _score(Ingredient ingredient, String query) {
    if (query.isEmpty) return 0;
    final name = ingredient.canonicalName.toLowerCase();
    final category = ingredient.category.toLowerCase();

    if (name == query) return 1000;
    if (name.startsWith(query)) return 800;
    if (name.contains(query)) return 600;
    if (category.contains(query)) return 300;
    return 0;
  }
}
