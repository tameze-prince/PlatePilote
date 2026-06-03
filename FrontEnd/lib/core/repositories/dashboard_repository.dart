import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'base_repository.dart';

/// Repository du tableau de bord, responsable des données agrégées
/// de la page d'accueil (plan, courses, garde-manger, budget, recommandations).
class DashboardRepository extends BaseRepository {
  DashboardRepository(super.apiClient);

  /// Récupère les données complètes du tableau de bord.
  Future<DashboardData> getHomeDashboard() async {
    try {
      final response = await apiClient.get('/dashboard/home');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return DashboardData.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

/// Données agrégées du tableau de bord affiché sur la page d'accueil.
class DashboardData {
  const DashboardData({
    this.firstName,
    this.planType,
    this.activePlan,
    this.groceryList,
    this.pantry,
    this.budget,
    this.unreadNotifications = 0,
    this.recommendations = const [],
    this.nextAction,
  });

  /// Prénom de l'utilisateur.
  final String? firstName;

  /// Type de plan actif.
  final String? planType;

  /// Résumé du plan de repas actif.
  final MealPlanSummary? activePlan;

  /// Résumé de la liste de courses.
  final GrocerySummary? groceryList;

  /// Résumé de l'état du garde-manger.
  final PantrySummary? pantry;

  /// Résumé du budget.
  final BudgetSummary? budget;

  /// Nombre de notifications non lues.
  final int unreadNotifications;

  /// Liste des recommandations personnalisées.
  final List<RecommendationItem> recommendations;

  /// Prochaine action suggérée.
  final String? nextAction;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      firstName: json['firstName'] as String?,
      planType: json['planType'] as String?,
      activePlan: json['activePlan'] != null
          ? MealPlanSummary.fromJson(json['activePlan'] as Map<String, dynamic>)
          : null,
      groceryList: json['groceryList'] != null
          ? GrocerySummary.fromJson(json['groceryList'] as Map<String, dynamic>)
          : null,
      pantry: json['pantry'] != null
          ? PantrySummary.fromJson(json['pantry'] as Map<String, dynamic>)
          : null,
      budget: json['budget'] != null
          ? BudgetSummary.fromJson(json['budget'] as Map<String, dynamic>)
          : null,
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
      recommendations: (json['recommendations'] as List?)
              ?.map((e) => RecommendationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextAction: json['nextAction'] as String?,
    );
  }
}

/// Résumé d'un plan de repas pour l'affichage dans le tableau de bord.
class MealPlanSummary {
  const MealPlanSummary({
    this.id,
    this.name,
    this.status,
    this.startDate,
    this.endDate,
    this.entryCount = 0,
  });

  /// Identifiant du plan.
  final String? id;

  /// Nom du plan.
  final String? name;

  /// Statut du plan (actif, terminé, etc.).
  final String? status;

  /// Date de début du plan.
  final String? startDate;

  /// Date de fin du plan.
  final String? endDate;

  /// Nombre d'entrées (repas) dans le plan.
  final int entryCount;

  factory MealPlanSummary.fromJson(Map<String, dynamic> json) {
    return MealPlanSummary(
      id: json['id'] as String?,
      name: json['name'] as String?,
      status: json['status'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      entryCount: (json['entryCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Résumé de la liste de courses avec progression.
class GrocerySummary {
  const GrocerySummary({
    this.id,
    this.name,
    this.totalItems = 0,
    this.checkedItems = 0,
    this.totalEstimate,
    this.checkedEstimate,
  });

  /// Identifiant de la liste.
  final String? id;

  /// Nom de la liste.
  final String? name;

  /// Nombre total d'articles.
  final int totalItems;

  /// Nombre d'articles cochés.
  final int checkedItems;

  /// Estimation totale du coût.
  final double? totalEstimate;

  /// Estimation du coût des articles cochés.
  final double? checkedEstimate;

  /// Progression en fraction (0.0 à 1.0).
  double get progress => totalItems > 0 ? checkedItems / totalItems : 0;

  factory GrocerySummary.fromJson(Map<String, dynamic> json) {
    return GrocerySummary(
      id: json['id'] as String?,
      name: json['name'] as String?,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      checkedItems: (json['checkedItems'] as num?)?.toInt() ?? 0,
      totalEstimate: (json['totalEstimate'] as num?)?.toDouble(),
      checkedEstimate: (json['checkedEstimate'] as num?)?.toDouble(),
    );
  }
}

/// Résumé de l'état du garde-manger (ruptures, péremptions).
class PantrySummary {
  const PantrySummary({
    this.totalItems = 0,
    this.expiringSoon = 0,
    this.expired = 0,
    this.lowStock = 0,
  });

  /// Nombre total d'articles.
  final int totalItems;

  /// Nombre d'articles proches de la date de péremption.
  final int expiringSoon;

  /// Nombre d'articles périmés.
  final int expired;

  /// Nombre d'articles en rupture de stock.
  final int lowStock;

  /// Vrai si au moins une alerte est active.
  bool get hasAlerts => expiringSoon > 0 || expired > 0 || lowStock > 0;

  /// Nombre total d'alertes.
  int get alertCount => expiringSoon + expired + lowStock;

  factory PantrySummary.fromJson(Map<String, dynamic> json) {
    return PantrySummary(
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      expiringSoon: (json['expiringSoon'] as num?)?.toInt() ?? 0,
      expired: (json['expired'] as num?)?.toInt() ?? 0,
      lowStock: (json['lowStock'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Résumé du budget avec suivi des dépenses.
class BudgetSummary {
  const BudgetSummary({
    this.amount,
    this.spent,
    this.currency,
  });

  /// Montant total du budget.
  final double? amount;

  /// Montant déjà dépensé.
  final double? spent;

  /// Devise utilisée.
  final String? currency;

  /// Montant restant.
  double get remaining => (amount ?? 0) - (spent ?? 0);

  /// Pourcentage du budget utilisé (0.0 à 1.0).
  double get percentUsed => (amount ?? 0) > 0 ? ((spent ?? 0) / (amount ?? 1)).clamp(0, 1) : 0;

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      amount: (json['amount'] as num?)?.toDouble(),
      spent: (json['spent'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }
}

/// Élément de recommandation (recette suggérée) affiché dans le tableau de bord.
class RecommendationItem {
  const RecommendationItem({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.totalTimeMinutes,
    this.servings,
    this.cuisineType,
    this.mealType,
    this.estimatedCost,
    this.score = 0,
  });

  /// Identifiant de la recette.
  final String? id;

  /// Nom de la recette.
  final String? name;

  /// Description courte.
  final String? description;

  /// URL de l'image.
  final String? imageUrl;

  /// Temps total de préparation en minutes.
  final int? totalTimeMinutes;

  /// Nombre de portions.
  final int? servings;

  /// Type de cuisine.
  final String? cuisineType;

  /// Type de repas.
  final String? mealType;

  /// Coût estimé.
  final double? estimatedCost;

  /// Score de pertinence (plus haut = plus recommandé).
  final double score;

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      totalTimeMinutes: json['totalTimeMinutes'] as int?,
      servings: json['servings'] as int?,
      cuisineType: json['cuisineType'] as String?,
      mealType: json['mealType'] as String?,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Provider Riverpod pour [DashboardRepository].
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider));
});
