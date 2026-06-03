import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';
import '../../core/repositories/preference_repository.dart';
import '../../core/repositories/profile_repository.dart';
import '../../features/onboarding/onboarding_state.dart';

/// Préférences modifiables par l'utilisateur.
class EditablePreferences {
  const EditablePreferences({
    this.householdSize = '2',
    this.cookingSkill = 'Balanced',
    this.weeklyBudget = r'$120',
    this.cookingTime = '30 min',
    this.dietaryPreferences = const {'High protein'},
    this.allergies = const {},
    this.goals = const {'Save money'},
    this.preferredCuisines = const {'Mediterranean'},
  });

  /// Taille du foyer.
  final String householdSize;
  /// Niveau de compétence culinaire.
  final String cookingSkill;
  /// Budget hebdomadaire.
  final String weeklyBudget;
  /// Temps de cuisson maximal.
  final String cookingTime;
  /// Préférences alimentaires.
  final Set<String> dietaryPreferences;
  /// Allergies déclarées.
  final Set<String> allergies;
  /// Objectifs utilisateur.
  final Set<String> goals;
  /// Cuisines préférées.
  final Set<String> preferredCuisines;

  /// Retourne une copie avec les champs modifiés.
  EditablePreferences copyWith({
    String? householdSize,
    String? cookingSkill,
    String? weeklyBudget,
    String? cookingTime,
    Set<String>? dietaryPreferences,
    Set<String>? allergies,
    Set<String>? goals,
    Set<String>? preferredCuisines,
  }) {
    return EditablePreferences(
      householdSize: householdSize ?? this.householdSize,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      cookingTime: cookingTime ?? this.cookingTime,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      allergies: allergies ?? this.allergies,
      goals: goals ?? this.goals,
      preferredCuisines: preferredCuisines ?? this.preferredCuisines,
    );
  }

  /// Convertit les préférences en Map pour JSON.
  Map<String, dynamic> toJson() => {
    'householdSize': householdSize,
    'cookingSkill': cookingSkill,
    'weeklyBudget': weeklyBudget,
    'cookingTime': cookingTime,
    'dietaryPreferences': dietaryPreferences.toList(),
    'allergies': allergies.toList(),
    'goals': goals.toList(),
    'preferredCuisines': preferredCuisines.toList(),
  };

  /// Crée une instance depuis une Map JSON.
  factory EditablePreferences.fromJson(Map<String, dynamic> json) {
    return EditablePreferences(
      householdSize: json['householdSize'] as String? ?? '2',
      cookingSkill: json['cookingSkill'] as String? ?? 'Balanced',
      weeklyBudget: json['weeklyBudget'] as String? ?? r'$120',
      cookingTime: json['cookingTime'] as String? ?? '30 min',
      dietaryPreferences:
          (json['dietaryPreferences'] as List<dynamic>?)
              ?.cast<String>()
              .toSet() ??
          const {'High protein'},
      allergies:
          (json['allergies'] as List<dynamic>?)?.cast<String>().toSet() ??
          const {},
      goals:
          (json['goals'] as List<dynamic>?)?.cast<String>().toSet() ??
          const {'Save money'},
      preferredCuisines:
          (json['preferredCuisines'] as List<dynamic>?)
              ?.cast<String>()
              .toSet() ??
          const {'Mediterranean'},
    );
  }
}

/// Notifier qui gère l'état des préférences éditables.
class PreferencesNotifier extends Notifier<EditablePreferences> {
  /// Clé SharedPreferences pour la persistance.
  static const _preferencesKey = 'preferences.editable';

  @override
  EditablePreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_preferencesKey);
    if (stored != null) {
      return EditablePreferences.fromJson(
        json.decode(stored) as Map<String, dynamic>,
      );
    }
    final onboarding = ref.watch(onboardingProvider);
    return EditablePreferences(
      householdSize: onboarding.householdSize ?? '2',
      cookingSkill: onboarding.cookingSkill ?? 'Balanced',
      weeklyBudget: onboarding.weeklyBudget ?? r'$120',
      cookingTime: onboarding.cookingTime ?? '30 min',
      dietaryPreferences: onboarding.dietaryPreferences.isEmpty
          ? const {'High protein'}
          : onboarding.dietaryPreferences,
      goals: onboarding.goals.isEmpty ? const {'Save money'} : onboarding.goals,
    );
  }

  /// Définit la taille du foyer.
  Future<void> setHouseholdSize(String value) async {
    state = state.copyWith(householdSize: value);
    await _persist();
  }

  /// Définit le niveau culinaire.
  Future<void> setCookingSkill(String value) async {
    state = state.copyWith(cookingSkill: value);
    await _persist();
  }

  /// Définit le budget hebdomadaire.
  Future<void> setWeeklyBudget(String value) async {
    state = state.copyWith(weeklyBudget: value);
    await _persist();
  }

  /// Définit le temps de cuisson.
  Future<void> setCookingTime(String value) async {
    state = state.copyWith(cookingTime: value);
    await _persist();
  }

  /// Ajoute ou retire une préférence alimentaire.
  Future<void> toggleDietaryPreference(String value) async {
    state = state.copyWith(
      dietaryPreferences: _toggle(state.dietaryPreferences, value),
    );
    await _persist();
  }

  /// Ajoute ou retire une allergie.
  Future<void> toggleAllergy(String value) async {
    state = state.copyWith(allergies: _toggle(state.allergies, value));
    await _persist();
  }

  /// Ajoute ou retire un objectif.
  Future<void> toggleGoal(String value) async {
    state = state.copyWith(goals: _toggle(state.goals, value));
    await _persist();
  }

  /// Ajoute ou retire une cuisine préférée.
  Future<void> toggleCuisine(String value) async {
    state = state.copyWith(
      preferredCuisines: _toggle(state.preferredCuisines, value),
    );
    await _persist();
  }

  /// Sauvegarde les préférences via l'API.
  Future<void> saveToApi() async {
    final prefRepo = ref.read(preferenceRepositoryProvider);
    await prefRepo.updateMyPreferences(
      dietaryPreferences: state.dietaryPreferences.toList(),
      allergies: state.allergies
          .map((a) => <String, String?>{'allergen': a, 'severity': null})
          .toList(),
      cuisines: state.preferredCuisines.toList(),
    );

    final profileRepo = ref.read(profileRepositoryProvider);
    await profileRepo.updateProfile(
      cookingSkill: state.cookingSkill,
      householdSize: int.tryParse(state.householdSize),
      healthGoals: state.goals.isNotEmpty ? state.goals.join(', ') : null,
    );
  }

  /// Persiste l'état actuel dans SharedPreferences.
  Future<void> _persist() async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(_preferencesKey, json.encode(state.toJson()));
  }

  /// Bascule une valeur dans un ensemble.
  Set<String> _toggle(Set<String> values, String value) {
    final next = {...values};
    next.contains(value) ? next.remove(value) : next.add(value);
    return next;
  }
}

/// Provider Riverpod pour les préférences éditables.
final editablePreferencesProvider =
    NotifierProvider<PreferencesNotifier, EditablePreferences>(
      PreferencesNotifier.new,
    );
