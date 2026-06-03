/// Modèle représentant un ingrédient avec ses informations nutritionnelles.
class Ingredient {
  /// Identifiant unique de l'ingrédient.
  final String id;
  /// Nom canonique.
  final String canonicalName;
  /// Slug unique.
  final String slug;
  /// Catégorie (ex: légume, épice).
  final String category;
  /// Description optionnelle.
  final String? description;
  /// Unité par défaut (ex: g, ml, unit).
  final String defaultUnit;
  /// Calories pour 100g.
  final double? caloriesPer100g;
  /// Protéines pour 100g.
  final double? proteinPer100g;
  /// Glucides pour 100g.
  final double? carbohydratesPer100g;
  /// Lipides pour 100g.
  final double? fatPer100g;
  /// Fibres pour 100g.
  final double? fiberPer100g;
  /// Sucres pour 100g.
  final double? sugarPer100g;
  /// Sodium en mg pour 100g.
  final double? sodiumMgPer100g;
  /// Cholestérol en mg pour 100g.
  final double? cholesterolMgPer100g;
  /// Contient du gluten.
  final bool? containsGluten;
  /// Contient du lactose.
  final bool? containsLactose;
  /// Contient des fruits à coque.
  final bool? containsNuts;
  /// Contient du soja.
  final bool? containsSoy;
  /// Contient des œufs.
  final bool? containsEggs;
  /// Contient du poisson.
  final bool? containsFish;
  /// Contient des crustacés.
  final bool? containsShellfish;
  /// Adapté aux végétaliens.
  final bool? vegan;
  /// Adapté aux végétariens.
  final bool? vegetarian;
  /// Halal friendly.
  final bool? halalFriendly;
  /// Kasher friendly.
  final bool? kosherFriendly;
  /// Faible en glucides.
  final bool? lowCarb;
  /// Compatible cétogène.
  final bool? ketoFriendly;
  /// Prix moyen au kg.
  final double? averagePricePerKg;
  /// Score de popularité.
  final int popularityScore;

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
    this.popularityScore = 0,
  });

  /// Crée un [Ingredient] depuis une map JSON.
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
      popularityScore:
          (json['popularityScore'] as num? ?? json['popularity'] as num?)
              ?.toInt() ??
          0,
    );
  }
}
