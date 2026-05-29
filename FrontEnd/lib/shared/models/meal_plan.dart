class MealPlan {
  const MealPlan({
    required this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.status,
    this.entries = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? name;
  final String? startDate;
  final String? endDate;
  final String? status;
  final List<MealPlanEntry> entries;
  final String? createdAt;
  final String? updatedAt;

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      status: json['status'] as String?,
      entries: (json['entries'] as List<dynamic>?)
              ?.map(
                  (e) => MealPlanEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}

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

  final String? id;
  final String? recipeId;
  final String? recipeName;
  final String? mealDate;
  final String? mealType;
  final int? servings;
  final String? notes;
  final int? totalTimeMinutes;
  final int? caloriesPerServing;
  final double? estimatedCost;
  final String? imageUrl;

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
