class Budget {
  const Budget({
    required this.id,
    this.amount,
    this.currency,
    this.period,
    this.startDate,
    this.endDate,
    this.spent,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final double? amount;
  final String? currency;
  final String? period;
  final String? startDate;
  final String? endDate;
  final double? spent;
  final String? createdAt;
  final String? updatedAt;

  double get remaining {
    if (amount == null) return 0;
    return amount! - (spent ?? 0);
  }

  double get percentUsed {
    if (amount == null || amount == 0) return 0;
    return ((spent ?? 0) / amount!).clamp(0.0, 1.0);
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      period: json['period'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      spent: (json['spent'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'period': period,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
