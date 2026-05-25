import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'base_repository.dart';

class PreferenceRepository extends BaseRepository {
  PreferenceRepository(super.apiClient);

  Future<List<String>> getDietaryPreferences() async {
    try {
      final response = await apiClient.get('/preferences/diets');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data.cast<String>();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> addDietaryPreference(String dietType) async {
    try {
      await apiClient.post('/preferences/diets', data: {'dietType': dietType});
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> removeDietaryPreference(String dietType) async {
    try {
      await apiClient.delete('/preferences/diets/$dietType');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<List<String>> getCuisinePreferences() async {
    try {
      final response = await apiClient.get('/preferences/cuisines');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data.cast<String>();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> addCuisinePreference(String cuisineType) async {
    try {
      await apiClient.post('/preferences/cuisines', data: {'cuisineType': cuisineType});
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> removeCuisinePreference(String cuisineType) async {
    try {
      await apiClient.delete('/preferences/cuisines/$cuisineType');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<List<dynamic>> getAllergies() async {
    try {
      final response = await apiClient.get('/preferences/allergies');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data;
      }
      return [];
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> addAllergy(String allergen, {String? severity}) async {
    try {
      await apiClient.post('/preferences/allergies', data: {
        'allergen': allergen,
        'severity': ?severity,
      });
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> removeAllergy(String allergen) async {
    try {
      await apiClient.delete('/preferences/allergies/$allergen');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> getMyPreferences() async {
    try {
      final response = await apiClient.get('/preferences/me');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> updateMyPreferences({
    List<String>? dietaryPreferences,
    List<Map<String, String?>>? allergies,
    List<String>? cuisines,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (dietaryPreferences != null) {
        data['dietaryPreferences'] = dietaryPreferences;
      }
      if (allergies != null) {
        data['allergies'] = allergies
            .map((a) => {'allergen': a['allergen'], 'severity': a['severity']})
            .toList();
      }
      if (cuisines != null) {
        data['cuisines'] = cuisines;
      }
      await apiClient.put('/preferences/me', data: data);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  return PreferenceRepository(ref.watch(apiClientProvider));
});
