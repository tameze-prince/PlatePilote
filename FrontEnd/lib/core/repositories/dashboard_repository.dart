import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'base_repository.dart';

class DashboardRepository extends BaseRepository {
  DashboardRepository(super.apiClient);

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

  final String? firstName;
  final String? planType;
  final MealPlanSummary? activePlan;
  final GrocerySummary? groceryList;
  final PantrySummary? pantry;
  final BudgetSummary? budget;
  final int unreadNotifications;
  final List<RecommendationItem> recommendations;
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

class MealPlanSummary {
  const MealPlanSummary({
    this.id,
    this.name,
    this.status,
    this.startDate,
    this.endDate,
    this.entryCount = 0,
  });

  final String? id;
  final String? name;
  final String? status;
  final String? startDate;
  final String? endDate;
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

class GrocerySummary {
  const GrocerySummary({
    this.id,
    this.name,
    this.totalItems = 0,
    this.checkedItems = 0,
    this.totalEstimate,
    this.checkedEstimate,
  });

  final String? id;
  final String? name;
  final int totalItems;
  final int checkedItems;
  final double? totalEstimate;
  final double? checkedEstimate;

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

class PantrySummary {
  const PantrySummary({
    this.totalItems = 0,
    this.expiringSoon = 0,
    this.expired = 0,
    this.lowStock = 0,
  });

  final int totalItems;
  final int expiringSoon;
  final int expired;
  final int lowStock;

  bool get hasAlerts => expiringSoon > 0 || expired > 0 || lowStock > 0;
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

class BudgetSummary {
  const BudgetSummary({
    this.amount,
    this.spent,
    this.currency,
  });

  final double? amount;
  final double? spent;
  final String? currency;

  double get remaining => (amount ?? 0) - (spent ?? 0);
  double get percentUsed => (amount ?? 0) > 0 ? ((spent ?? 0) / (amount ?? 1)).clamp(0, 1) : 0;

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      amount: (json['amount'] as num?)?.toDouble(),
      spent: (json['spent'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }
}

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

  final String? id;
  final String? name;
  final String? description;
  final String? imageUrl;
  final int? totalTimeMinutes;
  final int? servings;
  final String? cuisineType;
  final String? mealType;
  final double? estimatedCost;
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

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider));
});
