/// Modèle représentant un plan de repas complet.
class MealPlan {
  const MealPlan({
    required this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.status,
    this.mode,
    this.entries = const [],
    this.totalCost,
    this.totalTime,
    this.totalCalories,
    this.mealCount,
    this.costPerMeal,
    this.createdAt,
    this.updatedAt,
  });

  /// Identifiant unique du plan.
  final String id;
  /// Nom du plan.
  final String? name;
  /// Date de début.
  final String? startDate;
  /// Date de fin.
  final String? endDate;
  /// Statut du plan (ex: active, completed).
  final String? status;
  /// Mode de génération (auto, manual).
  final String? mode;
  /// Entrées (repas) du plan.
  final List<MealPlanEntry> entries;
  /// Coût total estimé.
  final double? totalCost;
  /// Temps total de préparation.
  final int? totalTime;
  /// Calories totales.
  final int? totalCalories;
  /// Nombre total de repas.
  final int? mealCount;
  /// Coût moyen par repas.
  final double? costPerMeal;
  /// Date de création.
  final String? createdAt;
  /// Date de dernière modification.
  final String? updatedAt;

  /// Crée un [MealPlan] depuis une map JSON.
  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      status: json['status'] as String?,
      mode: json['mode'] as String?,
      entries: (json['entries'] as List<dynamic>?)
              ?.map(
                  (e) => MealPlanEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCost: (json['totalCost'] as num?)?.toDouble(),
      totalTime: (json['totalTime'] as num?)?.toInt(),
      totalCalories: (json['totalCalories'] as num?)?.toInt(),
      mealCount: (json['mealCount'] as num?)?.toInt(),
      costPerMeal: (json['costPerMeal'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Convertit ce [MealPlan] en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'mode': mode,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}

/// Entrée individuelle dans un plan de repas.
class MealPlanEntry {
  const MealPlanEntry({
    this.id,
    this.recipeId,
    this.recipeName,
    this.mealDate,
    this.mealType,
    this.servings,
    this.notes,
    this.totalTimeMinutes,
    this.caloriesPerServing,
    this.estimatedCost,
    this.imageUrl,
  });

  /// Identifiant unique de l'entrée.
  final String? id;
  /// Identifiant de la recette associée.
  final String? recipeId;
  /// Nom de la recette.
  final String? recipeName;
  /// Date du repas.
  final String? mealDate;
  /// Type de repas (Breakfast, Lunch, Dinner).
  final String? mealType;
  /// Nombre de portions.
  final int? servings;
  /// Notes supplémentaires.
  final String? notes;
  /// Temps de préparation en minutes.
  final int? totalTimeMinutes;
  /// Calories par portion.
  final int? caloriesPerServing;
  /// Coût estimé.
  final double? estimatedCost;
  /// URL de l'image.
  final String? imageUrl;

  /// Crée une [MealPlanEntry] depuis une map JSON.
  factory MealPlanEntry.fromJson(Map<String, dynamic> json) {
    return MealPlanEntry(
      id: json['id']?.toString(),
      recipeId: json['recipeId']?.toString(),
      recipeName: json['recipeName'] as String?,
      mealDate: json['mealDate'] as String?,
      mealType: json['mealType'] as String?,
      servings: json['servings'] as int?,
      notes: json['notes'] as String?,
      totalTimeMinutes: (json['totalTimeMinutes'] as num?)?.toInt(),
      caloriesPerServing: (json['caloriesPerServing'] as num?)?.toInt(),
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Convertit cette [MealPlanEntry] en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'mealDate': mealDate,
      'mealType': mealType,
      'servings': servings,
      'notes': notes,
    };
  }
}
