import '../../shared/models/demo_data.dart';

class MealRecommendationConstraints {
  const MealRecommendationConstraints({
    required this.weeklyBudget,
    required this.remainingBudget,
    required this.householdSize,
    required this.cookingSkill,
    required this.availableCookingMinutes,
    required this.dietaryRestrictions,
    required this.allergies,
    required this.pantryContents,
    required this.preferredCuisines,
    required this.goals,
    this.groceryAdditionsAcceptable = true,
  });

  final double weeklyBudget;
  final double remainingBudget;
  final int householdSize;
  final String cookingSkill;
  final int availableCookingMinutes;
  final Set<String> dietaryRestrictions;
  final Set<String> allergies;
  final Set<String> pantryContents;
  final Set<String> preferredCuisines;
  final Set<String> goals;
  final bool groceryAdditionsAcceptable;
}

class RankedMeal {
  const RankedMeal({
    required this.meal,
    required this.score,
    required this.estimatedCost,
    required this.pantryMatchCount,
  });

  final Meal meal;
  final double score;
  final double estimatedCost;
  final int pantryMatchCount;
}

class MealConstraintsEngine {
  const MealConstraintsEngine();

  List<RankedMeal> rankMeals(
    List<Meal> meals,
    MealRecommendationConstraints constraints,
  ) {
    final ranked = <RankedMeal>[];

    for (final meal in meals) {
      if (meal.minutes > constraints.availableCookingMinutes) {
        continue;
      }

      if (_violatesDiet(meal, constraints.dietaryRestrictions)) {
        continue;
      }

      if (_violatesAllergies(meal, constraints.allergies)) {
        continue;
      }

      final estimatedCost = _estimateCost(meal, constraints.householdSize);
      if (estimatedCost > constraints.remainingBudget) {
        continue;
      }

      final pantryMatchCount = _pantryMatchCount(
        meal,
        constraints.pantryContents,
      );
      if (!constraints.groceryAdditionsAcceptable && pantryMatchCount == 0) {
        continue;
      }

      final budgetEfficiency = 1 - (estimatedCost / constraints.weeklyBudget);
      final pantryUtilization = pantryMatchCount / 4;
      final speedScore =
          1 - (meal.minutes / constraints.availableCookingMinutes);
      final goalBoost = constraints.goals.contains('Save money') ? 0.15 : 0;

      ranked.add(
        RankedMeal(
          meal: meal,
          score: budgetEfficiency + pantryUtilization + speedScore + goalBoost,
          estimatedCost: estimatedCost,
          pantryMatchCount: pantryMatchCount,
        ),
      );
    }

    ranked.sort((a, b) => b.score.compareTo(a.score));
    return ranked;
  }

  bool _violatesDiet(Meal meal, Set<String> dietaryRestrictions) {
    final title = meal.title.toLowerCase();
    if (dietaryRestrictions.contains('Vegetarian') &&
        (title.contains('salmon') ||
            title.contains('chicken') ||
            title.contains('turkey'))) {
      return true;
    }
    if (dietaryRestrictions.contains('Low carb') && title.contains('penne')) {
      return true;
    }
    return false;
  }

  bool _violatesAllergies(Meal meal, Set<String> allergies) {
    final title = meal.title.toLowerCase();
    return allergies.any((allergy) => title.contains(allergy.toLowerCase()));
  }

  double _estimateCost(Meal meal, int householdSize) {
    final base = meal.kcal / 100;
    return (base + (meal.minutes / 10)) * householdSize;
  }

  int _pantryMatchCount(Meal meal, Set<String> pantryContents) {
    final title = meal.title.toLowerCase();
    return pantryContents
        .where((ingredient) => title.contains(ingredient.toLowerCase()))
        .length;
  }
}
