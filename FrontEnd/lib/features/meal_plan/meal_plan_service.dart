import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../shared/models/meal_plan_dto.dart';

class MealPlanService {
  final ApiClient _client;
  MealPlanService(this._client);

  Future<List<MealPlanDto>> fetchWeeklyPlan() async {
    final response = await _client.get('/meal-plans/weekly');
    return (response.data as List).map((e) => MealPlanDto.fromJson(e)).toList();
  }
}

final mealPlanServiceProvider = Provider<MealPlanService>((ref) {
  return MealPlanService(ref.watch(apiClientProvider));
});
