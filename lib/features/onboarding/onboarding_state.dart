import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';

class OnboardingState {
  const OnboardingState({
    this.householdSize,
    this.cookingSkill,
    this.weeklyBudget,
    this.cookingTime,
    this.dietaryPreferences = const {},
    this.goals = const {},
  });

  final String? householdSize;
  final String? cookingSkill;
  final String? weeklyBudget;
  final String? cookingTime;
  final Set<String> dietaryPreferences;
  final Set<String> goals;

  bool get canContinueStepOne => householdSize != null && cookingSkill != null;
  bool get canContinueStepTwo =>
      weeklyBudget != null &&
      cookingTime != null &&
      dietaryPreferences.isNotEmpty;
  bool get canContinueStepThree => goals.isNotEmpty;

  OnboardingState copyWith({
    String? householdSize,
    String? cookingSkill,
    String? weeklyBudget,
    String? cookingTime,
    Set<String>? dietaryPreferences,
    Set<String>? goals,
  }) {
    return OnboardingState(
      householdSize: householdSize ?? this.householdSize,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      cookingTime: cookingTime ?? this.cookingTime,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      goals: goals ?? this.goals,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  static const _householdSizeKey = 'onboarding.householdSize';
  static const _cookingSkillKey = 'onboarding.cookingSkill';
  static const _weeklyBudgetKey = 'onboarding.weeklyBudget';
  static const _cookingTimeKey = 'onboarding.cookingTime';
  static const _dietaryPreferencesKey = 'onboarding.dietaryPreferences';
  static const _goalsKey = 'onboarding.goals';

  @override
  OnboardingState build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    return OnboardingState(
      householdSize: preferences.getString(_householdSizeKey),
      cookingSkill: preferences.getString(_cookingSkillKey),
      weeklyBudget: preferences.getString(_weeklyBudgetKey),
      cookingTime: preferences.getString(_cookingTimeKey),
      dietaryPreferences:
          (preferences.getStringList(_dietaryPreferencesKey) ?? const [])
              .toSet(),
      goals: (preferences.getStringList(_goalsKey) ?? const []).toSet(),
    );
  }

  Future<void> setHouseholdSize(String value) =>
      _setString(_householdSizeKey, state.copyWith(householdSize: value));

  Future<void> setCookingSkill(String value) =>
      _setString(_cookingSkillKey, state.copyWith(cookingSkill: value));

  Future<void> setWeeklyBudget(String value) =>
      _setString(_weeklyBudgetKey, state.copyWith(weeklyBudget: value));

  Future<void> setCookingTime(String value) =>
      _setString(_cookingTimeKey, state.copyWith(cookingTime: value));

  Future<void> toggleDietaryPreference(String value) async {
    final next = {...state.dietaryPreferences};
    next.contains(value) ? next.remove(value) : next.add(value);
    state = state.copyWith(dietaryPreferences: next);
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_dietaryPreferencesKey, next.toList());
  }

  Future<void> toggleGoal(String value) async {
    final next = {...state.goals};
    next.contains(value) ? next.remove(value) : next.add(value);
    state = state.copyWith(goals: next);
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_goalsKey, next.toList());
  }

  Future<void> _setString(String key, OnboardingState next) async {
    state = next;
    final value = switch (key) {
      _householdSizeKey => next.householdSize,
      _cookingSkillKey => next.cookingSkill,
      _weeklyBudgetKey => next.weeklyBudget,
      _cookingTimeKey => next.cookingTime,
      _ => null,
    };
    if (value != null) {
      await ref.read(sharedPreferencesProvider).setString(key, value);
    }
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
