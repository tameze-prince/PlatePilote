import '../../core/utils/date_utils.dart';

/// Article du garde-manger.
class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    this.category,
    this.quantity,
    this.unit,
    this.expirationDate,
    this.ingredientId,
    this.isExpired = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Identifiant unique.
  final String id;
  /// Nom de l'article.
  final String name;
  /// Catégorie (ex: Produce, Dairy).
  final String? category;
  /// Quantité disponible.
  final double? quantity;
  /// Unité de mesure.
  final String? unit;
  /// Date d'expiration.
  final String? expirationDate;
  /// Identifiant de l'ingrédient associé.
  final String? ingredientId;
  /// Indique si l'article est expiré.
  final bool isExpired;
  /// Date de création.
  final String? createdAt;
  /// Date de dernière modification.
  final String? updatedAt;

  /// Nombre de jours restants avant expiration.
  int? get daysToExpiry => AppDateUtils.daysUntil(expirationDate);

  /// Indique si l'article est urgent (expiré ou dans ≤2 jours).
  bool get isUrgent {
    final days = daysToExpiry;
    return isExpired || (days != null && days <= 2);
  }

  /// Indique si l'article expire bientôt (dans ≤7 jours).
  bool get isExpiringSoon {
    final days = daysToExpiry;
    return isExpired || (days != null && days <= 7);
  }

  /// Indique si le stock est bas (quantité < 1).
  bool get isLowStock => (quantity ?? 0) < 1;

  /// Retourne une copie avec les champs modifiés.
  PantryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    String? expirationDate,
    String? ingredientId,
    bool? isExpired,
    String? createdAt,
    String? updatedAt,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expirationDate: expirationDate ?? this.expirationDate,
      ingredientId: ingredientId ?? this.ingredientId,
      isExpired: isExpired ?? this.isExpired,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Crée un [PantryItem] depuis une map JSON.
  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      expirationDate: json['expirationDate'] as String?,
      ingredientId: json['ingredientId']?.toString(),
      isExpired: json['isExpired'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Convertit ce [PantryItem] en map JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expirationDate': expirationDate,
    };
  }
}
