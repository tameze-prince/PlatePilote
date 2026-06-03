import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'base_repository.dart';

/// Repository des préférences utilisateur (régimes, cuisines, allergies).
class PreferenceRepository extends BaseRepository {
  PreferenceRepository(super.apiClient);

  /// Récupère la liste des préférences alimentaires (régimes).
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

  /// Ajoute une préférence alimentaire.
  Future<void> addDietaryPreference(String dietType) async {
    try {
      await apiClient.post('/preferences/diets', data: {'dietType': dietType});
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Supprime une préférence alimentaire.
  Future<void> removeDietaryPreference(String dietType) async {
    try {
      await apiClient.delete('/preferences/diets/$dietType');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère la liste des préférences de cuisine.
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

  /// Ajoute une préférence de cuisine.
  Future<void> addCuisinePreference(String cuisineType) async {
    try {
      await apiClient.post('/preferences/cuisines', data: {'cuisineType': cuisineType});
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Supprime une préférence de cuisine.
  Future<void> removeCuisinePreference(String cuisineType) async {
    try {
      await apiClient.delete('/preferences/cuisines/$cuisineType');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère la liste des allergies déclarées.
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

  /// Ajoute une allergie avec une sévérité optionnelle.
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

  /// Supprime une allergie.
  Future<void> removeAllergy(String allergen) async {
    try {
      await apiClient.delete('/preferences/allergies/$allergen');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère toutes les préférences de l'utilisateur connecté.
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

  /// Met à jour les préférences de l'utilisateur connecté (régimes, allergies, cuisines).
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

/// Provider Riverpod pour [PreferenceRepository].
final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  return PreferenceRepository(ref.watch(apiClientProvider));
});
