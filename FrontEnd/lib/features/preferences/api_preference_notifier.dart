import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/preference_repository.dart';
import '../../core/repositories/profile_repository.dart';
import 'preferences_provider.dart';

/// Provider qui synchronise les préférences locales vers l'API.
final apiPreferencesProvider = FutureProvider<void>((ref) async {
  final local = ref.watch(editablePreferencesProvider);

  final profileRepo = ref.read(profileRepositoryProvider);
  final prefRepo = ref.read(preferenceRepositoryProvider);

  try {
    await profileRepo.updateProfile(
      householdSize: int.tryParse(local.householdSize),
      cookingSkill: local.cookingSkill,
      healthGoals: local.goals.isNotEmpty ? local.goals.join(', ') : null,
    );
  } catch (_) {}

  try {
    final existing = await prefRepo.getMyPreferences();
    final existingDiets = (existing['dietaryPreferences'] as List?)?.cast<String>() ?? [];
    final existingCuisines = (existing['cuisines'] as List?)?.cast<String>() ?? [];

    for (final diet in local.dietaryPreferences) {
      if (!existingDiets.any((d) => d.toLowerCase() == diet.toLowerCase())) {
        try { await prefRepo.addDietaryPreference(diet); } catch (_) {}
      }
    }

    for (final cuisine in local.preferredCuisines) {
      if (!existingCuisines.any((c) => c.toLowerCase() == cuisine.toLowerCase())) {
        try { await prefRepo.addCuisinePreference(cuisine); } catch (_) {}
      }
    }
  } catch (_) {}
});
