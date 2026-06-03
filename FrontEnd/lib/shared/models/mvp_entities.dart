/// Catégories de notification disponibles.
enum NotificationCategory { pantry, budget, mealPlan, grocery, premium }

/// Notification de l'application (version MVP).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.createdAt,
    this.isRead = false,
  });

  /// Identifiant unique.
  final String id;
  /// Titre de la notification.
  final String title;
  /// Message de la notification.
  final String message;
  /// Catégorie de la notification.
  final NotificationCategory category;
  /// Date de création.
  final DateTime createdAt;
  /// Indique si la notification a été lue.
  final bool isRead;

  /// Retourne une copie avec les champs modifiés.
  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      category: category,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Préférences utilisateur.
class UserPreferences {
  const UserPreferences({
    required this.householdSize,
    required this.cookingSkill,
    required this.weeklyBudget,
    required this.cookingTimeMinutes,
    required this.dietaryPreferences,
    required this.allergies,
    required this.goals,
    required this.preferredCuisines,
  });

  /// Taille du foyer.
  final int householdSize;
  /// Niveau de compétence culinaire.
  final String cookingSkill;
  /// Budget hebdomadaire.
  final double weeklyBudget;
  /// Minutes disponibles pour cuisiner.
  final int cookingTimeMinutes;
  /// Préférences alimentaires.
  final Set<String> dietaryPreferences;
  /// Allergies.
  final Set<String> allergies;
  /// Objectifs.
  final Set<String> goals;
  /// Cuisines préférées.
  final Set<String> preferredCuisines;
}

/// Entrée d'historique budgétaire.
class BudgetHistory {
  const BudgetHistory({
    required this.amount,
    required this.spent,
    required this.startedAt,
  });

  /// Montant budgété.
  final double amount;
  /// Montant dépensé.
  final double spent;
  /// Date de début de la période.
  final DateTime startedAt;
}

/// Recette personnalisée créée par l'utilisateur.
class CustomRecipe {
  const CustomRecipe({
    required this.name,
    required this.description,
    required this.preparationMinutes,
    required this.cookingMinutes,
    required this.difficulty,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    required this.estimatedCost,
  });

  /// Nom de la recette.
  final String name;
  /// Description de la recette.
  final String description;
  /// Minutes de préparation.
  final int preparationMinutes;
  /// Minutes de cuisson.
  final int cookingMinutes;
  /// Niveau de difficulté (Easy, Medium, Advanced).
  final String difficulty;
  /// Nombre de portions.
  final int servings;
  /// Liste des ingrédients.
  final List<String> ingredients;
  /// Liste des instructions.
  final List<String> instructions;
  /// Tags de la recette.
  final Set<String> tags;
  /// Coût estimé.
  final double estimatedCost;
}

/// Préférence de localisation/langue.
class LocalizationPreference {
  const LocalizationPreference({required this.languageCode});

  /// Code de langue (ex: en, fr).
  final String languageCode;
}
