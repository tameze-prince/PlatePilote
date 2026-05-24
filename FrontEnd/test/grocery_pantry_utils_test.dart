import 'package:flutter_test/flutter_test.dart';
import 'package:plate_pilote/core/utils/date_utils.dart';
import 'package:plate_pilote/core/utils/search_utils.dart';
import 'package:plate_pilote/shared/models/ingredient.dart';

void main() {
  test('daysUntil compares dates without time of day drift', () {
    final now = DateTime(2026, 5, 24, 23, 30);

    expect(AppDateUtils.daysUntil('2026-05-24', now: now), 0);
    expect(AppDateUtils.daysUntil('2026-05-26', now: now), 2);
    expect(AppDateUtils.daysUntil('2026-05-23', now: now), -1);
  });

  test('sortIngredients ranks exact, prefix, popularity, then alpha', () {
    const ingredients = [
      Ingredient(
        id: '1',
        canonicalName: 'Green apple',
        slug: 'green-apple',
        category: 'fruits',
        defaultUnit: 'piece',
        popularityScore: 10,
      ),
      Ingredient(
        id: '2',
        canonicalName: 'Apple',
        slug: 'apple',
        category: 'fruits',
        defaultUnit: 'piece',
        popularityScore: 1,
      ),
      Ingredient(
        id: '3',
        canonicalName: 'Apple juice',
        slug: 'apple-juice',
        category: 'beverages',
        defaultUnit: 'ml',
        popularityScore: 20,
      ),
    ];

    final sorted = SearchUtils.sortIngredients(ingredients, 'apple');

    expect(sorted.map((item) => item.canonicalName), [
      'Apple',
      'Apple juice',
      'Green apple',
    ]);
  });
}
