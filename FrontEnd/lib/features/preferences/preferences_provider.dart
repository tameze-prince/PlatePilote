import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';
import '../../core/repositories/preference_repository.dart';
import '../../core/repositories/profile_repository.dart';
import '../../features/onboarding/onboarding_state.dart';

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

  final String householdSize;
  final String cookingSkill;
  final String weeklyBudget;
  final String cookingTime;
  final Set<String> dietaryPreferences;
  final Set<String> allergies;
  final Set<String> goals;
  final Set<String> preferredCuisines;

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

class PreferencesNotifier extends Notifier<EditablePreferences> {
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

  Future<void> setHouseholdSize(String value) async {
    state = state.copyWith(householdSize: value);
    await _persist();
  }

  Future<void> setCookingSkill(String value) async {
    state = state.copyWith(cookingSkill: value);
    await _persist();
  }

  Future<void> setWeeklyBudget(String value) async {
    state = state.copyWith(weeklyBudget: value);
    await _persist();
  }

  Future<void> setCookingTime(String value) async {
    state = state.copyWith(cookingTime: value);
    await _persist();
  }

  Future<void> toggleDietaryPreference(String value) async {
    state = state.copyWith(
      dietaryPreferences: _toggle(state.dietaryPreferences, value),
    );
    await _persist();
  }

  Future<void> toggleAllergy(String value) async {
    state = state.copyWith(allergies: _toggle(state.allergies, value));
    await _persist();
  }

  Future<void> toggleGoal(String value) async {
    state = state.copyWith(goals: _toggle(state.goals, value));
    await _persist();
  }

  Future<void> toggleCuisine(String value) async {
    state = state.copyWith(
      preferredCuisines: _toggle(state.preferredCuisines, value),
    );
    await _persist();
  }

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

  Future<void> _persist() async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(_preferencesKey, json.encode(state.toJson()));
  }

  Set<String> _toggle(Set<String> values, String value) {
    final next = {...values};
    next.contains(value) ? next.remove(value) : next.add(value);
    return next;
  }
}

final editablePreferencesProvider =
    NotifierProvider<PreferencesNotifier, EditablePreferences>(
      PreferencesNotifier.new,
    );
