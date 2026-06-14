import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';

/// État du parcours d'onboarding.
class OnboardingState {
  /// Crée un [OnboardingState] avec des valeurs optionnelles.
  const OnboardingState({
    this.currentStep = 0,
    this.householdSize,
    this.cookingSkill,
    this.weeklyBudget,
    this.cookingTime,
    this.dietaryPreferences = const {},
    this.goals = const {},
  });

  /// Étape actuelle de l'onboarding (0 = non commencé, 1-3 = étapes).
  final int currentStep;
  /// Taille du foyer sélectionnée.
  final String? householdSize;
  /// Niveau de compétence culinaire.
  final String? cookingSkill;
  /// Budget hebdomadaire sélectionné.
  final String? weeklyBudget;
  /// Temps de cuisson maximal choisi.
  final String? cookingTime;
  /// Ensemble des préférences alimentaires.
  final Set<String> dietaryPreferences;
  /// Ensemble des objectifs utilisateur.
  final Set<String> goals;

  /// Vrai si l'étape 1 peut être validée.
  bool get canContinueStepOne => householdSize != null && cookingSkill != null;
  /// Vrai si l'étape 2 peut être validée.
  bool get canContinueStepTwo =>
      weeklyBudget != null &&
      cookingTime != null &&
      dietaryPreferences.isNotEmpty;
  /// Vrai si l'étape 3 peut être validée.
  bool get canContinueStepThree => goals.isNotEmpty;

  /// Retourne une copie avec les champs modifiés.
  OnboardingState copyWith({
    int? currentStep,
    String? householdSize,
    String? cookingSkill,
    String? weeklyBudget,
    String? cookingTime,
    Set<String>? dietaryPreferences,
    Set<String>? goals,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      householdSize: householdSize ?? this.householdSize,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      cookingTime: cookingTime ?? this.cookingTime,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      goals: goals ?? this.goals,
    );
  }
}

/// Notifier qui gère l'état de l'onboarding et persiste dans SharedPreferences.
class OnboardingNotifier extends Notifier<OnboardingState> {
  /// Clé SharedPreferences pour la taille du foyer.
  static const _householdSizeKey = 'onboarding.householdSize';
  /// Clé SharedPreferences pour le niveau culinaire.
  static const _cookingSkillKey = 'onboarding.cookingSkill';
  /// Clé SharedPreferences pour le budget hebdomadaire.
  static const _weeklyBudgetKey = 'onboarding.weeklyBudget';
  /// Clé SharedPreferences pour le temps de cuisson.
  static const _cookingTimeKey = 'onboarding.cookingTime';
  /// Clé SharedPreferences pour les préférences alimentaires.
  static const _dietaryPreferencesKey = 'onboarding.dietaryPreferences';
  /// Clé SharedPreferences pour les objectifs.
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

  /// Définit la taille du foyer et persiste.
  Future<void> setHouseholdSize(String value) =>
      _setString(_householdSizeKey, state.copyWith(householdSize: value));

  /// Définit le niveau culinaire et persiste.
  Future<void> setCookingSkill(String value) =>
      _setString(_cookingSkillKey, state.copyWith(cookingSkill: value));

  /// Définit le budget hebdomadaire et persiste.
  Future<void> setWeeklyBudget(String value) =>
      _setString(_weeklyBudgetKey, state.copyWith(weeklyBudget: value));

  /// Définit le temps de cuisson et persiste.
  Future<void> setCookingTime(String value) =>
      _setString(_cookingTimeKey, state.copyWith(cookingTime: value));

  /// Ajoute ou retire une préférence alimentaire et persiste.
  Future<void> toggleDietaryPreference(String value) async {
    final next = {...state.dietaryPreferences};
    next.contains(value) ? next.remove(value) : next.add(value);
    state = state.copyWith(dietaryPreferences: next);
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_dietaryPreferencesKey, next.toList());
  }

  /// Ajoute ou retire un objectif et persiste.
  Future<void> toggleGoal(String value) async {
    final next = {...state.goals};
    next.contains(value) ? next.remove(value) : next.add(value);
    state = state.copyWith(goals: next);
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_goalsKey, next.toList());
  }

  /// Réinitialise toutes les données d'onboarding.
  Future<void> reset() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_householdSizeKey);
    await prefs.remove(_cookingSkillKey);
    await prefs.remove(_weeklyBudgetKey);
    await prefs.remove(_cookingTimeKey);
    await prefs.remove(_dietaryPreferencesKey);
    await prefs.remove(_goalsKey);
    state = const OnboardingState();
  }

  /// Persiste une valeur simple (String) dans SharedPreferences.
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

/// Provider Riverpod pour l'état et le notifier d'onboarding.
final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
