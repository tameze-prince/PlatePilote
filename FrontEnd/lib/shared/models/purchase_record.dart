class PurchaseRecord {
  const PurchaseRecord({
    required this.id,
    required this.itemNames,
    required this.totalPrice,
    required this.boughtDate,
  });

  final String id;
  final List<String> itemNames;
  final double totalPrice;
  final DateTime boughtDate;

  String get formattedDate {
    final d = boughtDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
