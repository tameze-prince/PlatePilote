class GroceryList {
  const GroceryList({
    required this.id,
    this.name,
    this.status,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? name;
  final String? status;
  final List<GroceryItem> items;
  final String? createdAt;
  final String? updatedAt;

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      status: json['status'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => GroceryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

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
  });

  final String? id;
  final String name;
  final String? category;
  final double? quantity;
  final String? unit;
  final double? estimatedPrice;
  final double? priceConfidence;
  final bool checked;
  final String? notes;
  final int? sortOrder;
  final String? ingredientId;

  GroceryItem copyWith({bool? checked}) {
    return GroceryItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      estimatedPrice: estimatedPrice,
      priceConfidence: priceConfidence,
      checked: checked ?? this.checked,
      notes: notes,
      sortOrder: sortOrder,
      ingredientId: ingredientId,
    );
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id']?.toString(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      estimatedPrice:
          (json['estimatedPrice'] as num?)?.toDouble(),
      priceConfidence:
          (json['priceConfidence'] as num?)?.toDouble(),
      checked: json['checked'] as bool? ?? false,
      notes: json['notes'] as String?,
      sortOrder: json['sortOrder'] as int?,
      ingredientId: json['ingredientId']?.toString(),
    );
  }

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
    };
  }
}
