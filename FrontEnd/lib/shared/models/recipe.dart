/// Modèle représentant une recette complète.
class Recipe {
  const Recipe({
    required this.id,
    this.name,
    this.description,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.totalTimeMinutes,
    this.servings,
    this.difficulty,
    this.cuisineType,
    this.mealType,
    this.imageUrl,
    this.source,
    this.isPublic,
    this.userId,
    this.ingredients = const [],
    this.steps = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Identifiant unique de la recette.
  final String id;
  /// Nom de la recette.
  final String? name;
  /// Description.
  final String? description;
  /// Minutes de préparation.
  final int? prepTimeMinutes;
  /// Minutes de cuisson.
  final int? cookTimeMinutes;
  /// Minutes totales.
  final int? totalTimeMinutes;
  /// Nombre de portions.
  final int? servings;
  /// Niveau de difficulté.
  final String? difficulty;
  /// Type de cuisine.
  final String? cuisineType;
  /// Type de repas.
  final String? mealType;
  /// URL de l'image.
  final String? imageUrl;
  /// Source de la recette.
  final String? source;
  /// Visibilité publique.
  final bool? isPublic;
  /// Identifiant du créateur.
  final String? userId;
  /// Ingrédients de la recette.
  final List<RecipeIngredient> ingredients;
  /// Étapes de la recette.
  final List<RecipeStep> steps;
  /// Date de création.
  final String? createdAt;
  /// Date de mise à jour.
  final String? updatedAt;

  /// Crée une [Recipe] depuis une map JSON.
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      description: json['description'] as String?,
      prepTimeMinutes: json['prepTimeMinutes'] as int?,
      cookTimeMinutes: json['cookTimeMinutes'] as int?,
      totalTimeMinutes: json['totalTimeMinutes'] as int?,
      servings: json['servings'] as int?,
      difficulty: json['difficulty'] as String?,
      cuisineType: json['cuisineType'] as String?,
      mealType: json['mealType'] as String?,
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String?,
      isPublic: json['isPublic'] as bool?,
      userId: json['userId']?.toString(),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) =>
                  RecipeIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      steps: (json['steps'] as List<dynamic>?)
              ?.map(
                  (e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Convertit cette [Recipe] en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'totalTimeMinutes': totalTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'cuisineType': cuisineType,
      'mealType': mealType,
      'imageUrl': imageUrl,
      'source': source,
      'isPublic': isPublic,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps.map((e) => e.toJson()).toList(),
    };
  }
}

/// Ingrédient d'une recette.
class RecipeIngredient {
  const RecipeIngredient({
    this.id,
    required this.name,
    this.quantity,
    this.unit,
    this.notes,
    this.sortOrder,
    this.ingredientId,
  });

  /// Identifiant unique.
  final String? id;
  /// Nom de l'ingrédient.
  final String name;
  /// Quantité nécessaire.
  final double? quantity;
  /// Unité de mesure.
  final String? unit;
  /// Notes supplémentaires.
  final String? notes;
  /// Ordre d'affichage.
  final int? sortOrder;
  /// Identifiant de l'ingrédient référencé.
  final String? ingredientId;

  /// Crée un [RecipeIngredient] depuis une map JSON.
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id']?.toString(),
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
      sortOrder: json['sortOrder'] as int?,
      ingredientId: json['ingredientId']?.toString(),
    );
  }

  /// Convertit ce [RecipeIngredient] en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'sortOrder': sortOrder,
    };
  }
}

/// Étape d'une recette.
class RecipeStep {
  const RecipeStep({
    this.id,
    required this.stepNumber,
    required this.instruction,
    this.durationMinutes,
  });

  /// Identifiant unique.
  final String? id;
  /// Numéro de l'étape.
  final int stepNumber;
  /// Instruction textuelle.
  final String instruction;
  /// Durée estimée en minutes.
  final int? durationMinutes;

  /// Crée un [RecipeStep] depuis une map JSON.
  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id']?.toString(),
      stepNumber: json['stepNumber'] as int? ?? 0,
      instruction: json['instruction'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int?,
    );
  }

  /// Convertit ce [RecipeStep] en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'instruction': instruction,
      'durationMinutes': durationMinutes,
    };
  }
}
