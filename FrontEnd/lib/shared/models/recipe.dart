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

  final String id;
  final String? name;
  final String? description;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? totalTimeMinutes;
  final int? servings;
  final String? difficulty;
  final String? cuisineType;
  final String? mealType;
  final String? imageUrl;
  final String? source;
  final bool? isPublic;
  final String? userId;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final String? createdAt;
  final String? updatedAt;

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

  final String? id;
  final String name;
  final double? quantity;
  final String? unit;
  final String? notes;
  final int? sortOrder;
  final String? ingredientId;

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

class RecipeStep {
  const RecipeStep({
    this.id,
    required this.stepNumber,
    required this.instruction,
    this.durationMinutes,
  });

  final String? id;
  final int stepNumber;
  final String instruction;
  final int? durationMinutes;

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id']?.toString(),
      stepNumber: json['stepNumber'] as int? ?? 0,
      instruction: json['instruction'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'instruction': instruction,
      'durationMinutes': durationMinutes,
    };
  }
}
