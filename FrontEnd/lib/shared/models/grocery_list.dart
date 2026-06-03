/// Modèle représentant une liste de courses.
class GroceryList {
  const GroceryList({
    required this.id,
    this.name,
    this.status,
    this.items = const [],
    this.mealPlanId,
    this.createdAt,
    this.updatedAt,
  });

  /// Identifiant unique de la liste.
  final String id;
  /// Nom de la liste.
  final String? name;
  /// Statut de la liste.
  final String? status;
  /// Articles de la liste.
  final List<GroceryItem> items;
  /// Identifiant du plan de repas associé.
  final String? mealPlanId;
  /// Date de création.
  final String? createdAt;
  /// Date de dernière modification.
  final String? updatedAt;

  /// Crée une [GroceryList] depuis une map JSON.
  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      status: json['status'] as String?,
      mealPlanId: json['mealPlanId']?.toString(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => GroceryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Convertit cette [GroceryList] en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

/// Article individuel dans une liste de courses.
class GroceryItem {
  const GroceryItem({
    this.id,
    required this.name,
    this.category,
    this.quantity,
    this.unit,
    this.estimatedPrice,
    this.priceConfidence,
    this.checked = false,
    this.notes,
    this.sortOrder,
    this.ingredientId,
    this.isHighPriority = false,
    this.lastPurchased,
  });

  /// Identifiant unique de l'article.
  final String? id;
  /// Nom de l'article.
  final String name;
  /// Catégorie (ex: Produce, Dairy).
  final String? category;
  /// Quantité.
  final double? quantity;
  /// Unité de mesure.
  final String? unit;
  /// Prix estimé.
  final double? estimatedPrice;
  /// Niveau de confiance du prix.
  final double? priceConfidence;
  /// Indique si l'article est coché (acheté).
  final bool checked;
  /// Notes supplémentaires.
  final String? notes;
  /// Ordre d'affichage.
  final int? sortOrder;
  /// Identifiant de l'ingrédient associé.
  final String? ingredientId;
  /// Indique si l'article est haute priorité.
  final bool isHighPriority;
  /// Date du dernier achat.
  final String? lastPurchased;

  /// Retourne une copie avec les champs modifiés.
  GroceryItem copyWith({
    bool? checked,
    double? quantity,
    String? unit,
    String? name,
    String? notes,
    bool? isHighPriority,
    String? lastPurchased,
  }) {
    return GroceryItem(
      id: id,
      name: name ?? this.name,
      category: category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedPrice: estimatedPrice,
      priceConfidence: priceConfidence,
      checked: checked ?? this.checked,
      notes: notes ?? this.notes,
      sortOrder: sortOrder,
      ingredientId: ingredientId,
      isHighPriority: isHighPriority ?? this.isHighPriority,
      lastPurchased: lastPurchased ?? this.lastPurchased,
    );
  }

  /// Crée un [GroceryItem] depuis une map JSON.
  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id']?.toString(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      priceConfidence: (json['priceConfidence'] as num?)?.toDouble(),
      checked: json['checked'] as bool? ?? false,
      notes: json['notes'] as String?,
      sortOrder: json['sortOrder'] as int?,
      ingredientId: json['ingredientId']?.toString(),
      isHighPriority:
          json['isHighPriority'] as bool? ??
          json['highPriority'] as bool? ??
          false,
      lastPurchased: json['lastPurchased'] as String?,
    );
  }

  /// Convertit cet [GroceryItem] en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'estimatedPrice': estimatedPrice,
      'checked': checked,
      'notes': notes,
      'sortOrder': sortOrder,
      'isHighPriority': isHighPriority,
      'lastPurchased': lastPurchased,
    };
  }
}
