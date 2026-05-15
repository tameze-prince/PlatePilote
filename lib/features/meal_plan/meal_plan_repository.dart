import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/meal_plan_dto.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepository(ref.watch(apiClientProvider));
});

class MealPlanRepository {
  const MealPlanRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<MealPlanDto>> fetchWeeklyPlan() async {
    final response = await _apiClient.get('/meal-plans/current');
    final data = response.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(MealPlanDto.fromJson).toList();
  }
}
