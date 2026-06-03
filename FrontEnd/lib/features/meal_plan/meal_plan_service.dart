import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/meal_plan_dto.dart';

/// Service pour les opérations sur les plans de repas.
/// (Non utilisé actuellement, remplacé par [MealPlanRepository]).
class MealPlanService {
  final ApiClient _client;
  MealPlanService(this._client);

  /// Récupère le plan de repas hebdomadaire.
  Future<List<MealPlanDto>> fetchWeeklyPlan() async {
    final response = await _client.get('/meal-plans/weekly');
    return (response.data as List).map((e) => MealPlanDto.fromJson(e)).toList();
  }
}

/// Fournisseur du service de plans de repas.
final mealPlanServiceProvider = Provider<MealPlanService>((ref) {
  return MealPlanService(ref.watch(apiClientProvider));
});
