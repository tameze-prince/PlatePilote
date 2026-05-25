class PurchaseRecord {
  PurchaseRecord({
    required this.id,
    required this.itemNames,
    required this.totalPrice,
    required this.boughtDate,
  });

  final String id;
  final List<String> itemNames;
  final double totalPrice;
  final DateTime boughtDate;

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemNames': itemNames,
        'totalPrice': totalPrice,
        'boughtDate': boughtDate.toIso8601String(),
      };

  String get formattedDate {
    final d = boughtDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
