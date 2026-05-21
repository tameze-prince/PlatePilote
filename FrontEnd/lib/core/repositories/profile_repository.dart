import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'base_repository.dart';

class ProfileRepository extends BaseRepository {
  ProfileRepository(super.apiClient);

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await apiClient.get('/profile');
      return handleResponse(response, (data) => data);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> updateProfile({
    String? cookingSkill,
    int? householdSize,
    String? healthGoals,
    String? countryCode,
    String? currencyCode,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? locale,
    String? dateOfBirth,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (cookingSkill != null) data['cookingSkill'] = cookingSkill;
      if (householdSize != null) data['householdSize'] = householdSize;
      if (healthGoals != null) data['healthGoals'] = healthGoals;
      if (countryCode != null) data['countryCode'] = countryCode;
      if (currencyCode != null) data['currencyCode'] = currencyCode;
      if (gender != null) data['gender'] = gender;
      if (heightCm != null) data['heightCm'] = heightCm;
      if (weightKg != null) data['weightKg'] = weightKg;
      if (activityLevel != null) data['activityLevel'] = activityLevel;
      if (locale != null) data['locale'] = locale;
      if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
      await apiClient.put('/profile', data: data);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});
