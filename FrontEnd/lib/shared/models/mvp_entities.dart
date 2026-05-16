enum NotificationCategory { pantry, budget, mealPlan, grocery, premium }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;

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

  final int householdSize;
  final String cookingSkill;
  final double weeklyBudget;
  final int cookingTimeMinutes;
  final Set<String> dietaryPreferences;
  final Set<String> allergies;
  final Set<String> goals;
  final Set<String> preferredCuisines;
}

class BudgetHistory {
  const BudgetHistory({
    required this.amount,
    required this.spent,
    required this.startedAt,
  });

  final double amount;
  final double spent;
  final DateTime startedAt;
}

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

  final String name;
  final String description;
  final int preparationMinutes;
  final int cookingMinutes;
  final String difficulty;
  final int servings;
  final List<String> ingredients;
  final List<String> instructions;
  final Set<String> tags;
  final double estimatedCost;
}

class LocalizationPreference {
  const LocalizationPreference({required this.languageCode});

  final String languageCode;
}
