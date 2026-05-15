import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

class PreferencesNotifier extends Notifier<EditablePreferences> {
  @override
  EditablePreferences build() {
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

  void setHouseholdSize(String value) {
    state = state.copyWith(householdSize: value);
  }

  void setCookingSkill(String value) {
    state = state.copyWith(cookingSkill: value);
  }

  void setWeeklyBudget(String value) {
    state = state.copyWith(weeklyBudget: value);
  }

  void setCookingTime(String value) {
    state = state.copyWith(cookingTime: value);
  }

  void toggleDietaryPreference(String value) {
    state = state.copyWith(
      dietaryPreferences: _toggle(state.dietaryPreferences, value),
    );
  }

  void toggleAllergy(String value) {
    state = state.copyWith(allergies: _toggle(state.allergies, value));
  }

  void toggleGoal(String value) {
    state = state.copyWith(goals: _toggle(state.goals, value));
  }

  void toggleCuisine(String value) {
    state = state.copyWith(
      preferredCuisines: _toggle(state.preferredCuisines, value),
    );
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
