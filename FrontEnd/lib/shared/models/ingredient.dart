class Ingredient {
  final String id;
  final String canonicalName;
  final String slug;
  final String category;
  final String? description;
  final String defaultUnit;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbohydratesPer100g;
  final double? fatPer100g;
  final double? fiberPer100g;
  final double? sugarPer100g;
  final double? sodiumMgPer100g;
  final double? cholesterolMgPer100g;
  final bool? containsGluten;
  final bool? containsLactose;
  final bool? containsNuts;
  final bool? containsSoy;
  final bool? containsEggs;
  final bool? containsFish;
  final bool? containsShellfish;
  final bool? vegan;
  final bool? vegetarian;
  final bool? halalFriendly;
  final bool? kosherFriendly;
  final bool? lowCarb;
  final bool? ketoFriendly;
  final double? averagePricePerKg;

  const Ingredient({
    required this.id,
    required this.canonicalName,
    required this.slug,
    required this.category,
    this.description,
    required this.defaultUnit,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbohydratesPer100g,
    this.fatPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    this.sodiumMgPer100g,
    this.cholesterolMgPer100g,
    this.containsGluten,
    this.containsLactose,
    this.containsNuts,
    this.containsSoy,
    this.containsEggs,
    this.containsFish,
    this.containsShellfish,
    this.vegan,
    this.vegetarian,
    this.halalFriendly,
    this.kosherFriendly,
    this.lowCarb,
    this.ketoFriendly,
    this.averagePricePerKg,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id']?.toString() ?? '',
      canonicalName: json['canonicalName'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
      defaultUnit: json['defaultUnit'] as String? ?? 'unit',
      caloriesPer100g: (json['caloriesPer100g'] as num?)?.toDouble(),
      proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble(),
      carbohydratesPer100g: (json['carbohydratesPer100g'] as num?)?.toDouble(),
      fatPer100g: (json['fatPer100g'] as num?)?.toDouble(),
      fiberPer100g: (json['fiberPer100g'] as num?)?.toDouble(),
      sugarPer100g: (json['sugarPer100g'] as num?)?.toDouble(),
      sodiumMgPer100g: (json['sodiumMgPer100g'] as num?)?.toDouble(),
      cholesterolMgPer100g: (json['cholesterolMgPer100g'] as num?)?.toDouble(),
      containsGluten: json['containsGluten'] as bool?,
      containsLactose: json['containsLactose'] as bool?,
      containsNuts: json['containsNuts'] as bool?,
      containsSoy: json['containsSoy'] as bool?,
      containsEggs: json['containsEggs'] as bool?,
      containsFish: json['containsFish'] as bool?,
      containsShellfish: json['containsShellfish'] as bool?,
      vegan: json['vegan'] as bool?,
      vegetarian: json['vegetarian'] as bool?,
      halalFriendly: json['halalFriendly'] as bool?,
      kosherFriendly: json['kosherFriendly'] as bool?,
      lowCarb: json['lowCarb'] as bool?,
      ketoFriendly: json['ketoFriendly'] as bool?,
      averagePricePerKg: (json['averagePricePerKg'] as num?)?.toDouble(),
    );
  }
}
