/// Modèle représentant un budget utilisateur.
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

  /// Identifiant unique du budget.
  final String id;
  /// Montant total du budget.
  final double? amount;
  /// Devise du budget.
  final String? currency;
  /// Période du budget (ex: weekly, monthly).
  final String? period;
  /// Date de début du budget.
  final String? startDate;
  /// Date de fin du budget.
  final String? endDate;
  /// Montant déjà dépensé.
  final double? spent;
  /// Date de création.
  final String? createdAt;
  /// Date de dernière modification.
  final String? updatedAt;

  /// Montant restant dans le budget.
  double get remaining {
    if (amount == null) return 0;
    return amount! - (spent ?? 0);
  }

  /// Pourcentage du budget utilisé (entre 0 et 1).
  double get percentUsed {
    if (amount == null || amount == 0) return 0;
    return ((spent ?? 0) / amount!).clamp(0.0, 1.0);
  }

  /// Crée un [Budget] depuis une map JSON.
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

  /// Convertit ce [Budget] en map JSON.
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
