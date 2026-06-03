import '../../shared/models/demo_data.dart';

/// Contraintes pour les recommandations de repas.
@Deprecated('No longer used. Will be removed in a future version.')
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

  /// Budget hebdomadaire total.
  final double weeklyBudget;
  /// Budget restant pour la semaine.
  final double remainingBudget;
  /// Taille du foyer.
  final int householdSize;
  /// Niveau de compétence culinaire.
  final String cookingSkill;
  /// Minutes disponibles pour cuisiner.
  final int availableCookingMinutes;
  /// Restrictions alimentaires.
  final Set<String> dietaryRestrictions;
  /// Allergies alimentaires.
  final Set<String> allergies;
  /// Ingrédients disponibles dans le garde-manger.
  final Set<String> pantryContents;
  /// Cuisines préférées.
  final Set<String> preferredCuisines;
  /// Objectifs nutritionnels.
  final Set<String> goals;
  /// Indique si des achats supplémentaires sont acceptables.
  final bool groceryAdditionsAcceptable;
}

/// Repas classé avec un score de recommandation.
@Deprecated('No longer used. Will be removed in a future version.')
class RankedMeal {
  const RankedMeal({
    required this.meal,
    required this.score,
    required this.estimatedCost,
    required this.pantryMatchCount,
  });

  /// Le repas.
  final Meal meal;
  /// Score de recommandation.
  final double score;
  /// Coût estimé.
  final double estimatedCost;
  /// Nombre d'ingrédients correspondant au garde-manger.
  final int pantryMatchCount;
}

/// Moteur de classement des repas selon les contraintes utilisateur.
@Deprecated('No longer used. Will be removed in a future version.')
class MealConstraintsEngine {
  const MealConstraintsEngine();

  /// Classe les repas selon les contraintes données.
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

  /// Vérifie si le repas viole les restrictions alimentaires.
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

  /// Vérifie si le repas viole les allergies.
  bool _violatesAllergies(Meal meal, Set<String> allergies) {
    final title = meal.title.toLowerCase();
    return allergies.any((allergy) => title.contains(allergy.toLowerCase()));
  }

  /// Estime le coût d'un repas pour un foyer donné.
  double _estimateCost(Meal meal, int householdSize) {
    final base = meal.kcal / 100;
    return (base + (meal.minutes / 10)) * householdSize;
  }

  /// Compte le nombre d'ingrédients du garde-manger utilisés.
  int _pantryMatchCount(Meal meal, Set<String> pantryContents) {
    final title = meal.title.toLowerCase();
    return pantryContents
        .where((ingredient) => title.contains(ingredient.toLowerCase()))
        .length;
  }
}
