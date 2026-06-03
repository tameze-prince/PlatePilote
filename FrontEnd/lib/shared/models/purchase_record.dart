/// Enregistrement d'un achat effectué.
class PurchaseRecord {
  PurchaseRecord({
    required this.id,
    required this.itemNames,
    required this.totalPrice,
    required this.boughtDate,
  });

  /// Identifiant unique.
  final String id;
  /// Noms des articles achetés.
  final List<String> itemNames;
  /// Prix total de l'achat.
  final double totalPrice;
  /// Date de l'achat.
  final DateTime boughtDate;

  /// Crée un [PurchaseRecord] depuis une map JSON.
  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'] as String? ?? '',
      itemNames: (json['itemNames'] as List?)?.map((e) => e.toString()).toList() ?? [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      boughtDate: json['boughtDate'] != null
          ? DateTime.parse(json['boughtDate'] as String)
          : DateTime.now(),
    );
  }

  /// Convertit ce [PurchaseRecord] en map JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'itemNames': itemNames,
        'totalPrice': totalPrice,
        'boughtDate': boughtDate.toIso8601String(),
      };

  /// Date formatée (YYYY-MM-DD).
  String get formattedDate {
    final d = boughtDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
