import '../../core/utils/date_utils.dart';

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

  final String id;
  final String name;
  final String? category;
  final double? quantity;
  final String? unit;
  final String? expirationDate;
  final String? ingredientId;
  final bool isExpired;
  final String? createdAt;
  final String? updatedAt;

  int? get daysToExpiry => AppDateUtils.daysUntil(expirationDate);

  bool get isUrgent {
    final days = daysToExpiry;
    return isExpired || (days != null && days <= 2);
  }

  bool get isExpiringSoon {
    final days = daysToExpiry;
    return isExpired || (days != null && days <= 7);
  }

  bool get isLowStock => (quantity ?? 0) < 1;

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
