import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';
import 'onboarding_draft.dart';

/// Clé SharedPreferences du brouillon d'onboarding.
const _draftKey = 'pp.onboarding.draft.v1';

/// État du parcours d'onboarding.
class OnboardingState {
  /// Crée un [OnboardingState] avec des valeurs optionnelles.
  const OnboardingState({
    this.currentStep = 0,
    this.householdSize,
    this.cookingSkill,
    this.weeklyBudget,
    this.customBudget,
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
  /// Budget hebdomadaire sélectionné (clé : `$75`, `$120`, `$180` ou `'Custom'`).
  final String? weeklyBudget;
  /// Montant exact du budget personnalisé (range 20-500).
  final double? customBudget;
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

  /// Convertit l'état courant en DTO persistant.
  OnboardingDraft toDraft() => OnboardingDraft(
        currentStep: currentStep,
        completedSteps: List.generate(currentStep, (i) => i.toString()),
        householdSize: householdSize,
        cookingProfile: cookingSkill,
        weeklyBudget: weeklyBudget,
        customBudget: customBudget,
        cookingTime: cookingTime,
        dietaryPreferences: dietaryPreferences.toList(),
        goals: goals.toList(),
        updatedAt: DateTime.now(),
      );

  /// Construit un état à partir d'un DTO persisté.
  factory OnboardingState.fromDraft(OnboardingDraft draft) => OnboardingState(
        currentStep: draft.currentStep,
        householdSize: draft.householdSize,
        cookingSkill: draft.cookingProfile,
        weeklyBudget: draft.weeklyBudget,
        customBudget: draft.customBudget,
        cookingTime: draft.cookingTime,
        dietaryPreferences: draft.dietaryPreferences.toSet(),
        goals: draft.goals.toSet(),
      );

  /// Retourne une copie avec les champs modifiés.
  OnboardingState copyWith({
    int? currentStep,
    String? householdSize,
    String? cookingSkill,
    String? weeklyBudget,
    double? customBudget,
    String? cookingTime,
    Set<String>? dietaryPreferences,
    Set<String>? goals,
    bool clearCustomBudget = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      householdSize: householdSize ?? this.householdSize,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      customBudget:
          clearCustomBudget ? null : (customBudget ?? this.customBudget),
      cookingTime: cookingTime ?? this.cookingTime,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      goals: goals ?? this.goals,
    );
  }
}

/// Notifier qui gère l'état de l'onboarding et persiste les brouillons.
class OnboardingNotifier extends Notifier<OnboardingState> {
  Timer? _persistTimer;

  @override
  OnboardingState build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    final raw = preferences.getString(_draftKey);
    ref.onDispose(() => _persistTimer?.cancel());
    if (raw != null) {
      try {
        final draft = OnboardingDraft.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        return OnboardingState.fromDraft(draft);
      } on FormatException {
        // Brouillon corrompu : on l'ignore et repart d'un état vierge.
      }
    }
    return const OnboardingState();
  }

  /// Définit la taille du foyer.
  void setHouseholdSize(String value) {
    state = state.copyWith(householdSize: value);
    _schedulePersist();
  }

  /// Définit le niveau culinaire.
  void setCookingSkill(String value) {
    state = state.copyWith(cookingSkill: value);
    _schedulePersist();
  }

  /// Définit l'option de budget prédéfinie (`$75`, `$120`, `$180`) ou
  /// remet le mode `Custom` sans montant saisi.
  void setWeeklyBudget(String value) {
    final isCustom = value == 'Custom';
    state = state.copyWith(
      weeklyBudget: value,
      clearCustomBudget: !isCustom,
    );
    _schedulePersist();
  }

  /// Définit le montant exact du budget personnalisé.
  void setCustomBudget(double value) {
    state = state.copyWith(
      weeklyBudget: value.toStringAsFixed(0),
      customBudget: value,
    );
    _schedulePersist();
  }

  /// Définit le temps de cuisson.
  void setCookingTime(String value) {
    state = state.copyWith(cookingTime: value);
    _schedulePersist();
  }

  /// Ajoute ou retire une préférence alimentaire.
  void toggleDietaryPreference(String value) {
    final next = {...state.dietaryPreferences};
    next.contains(value) ? next.remove(value) : next.add(value);
    state = state.copyWith(dietaryPreferences: next);
    _schedulePersist();
  }

  /// Ajoute ou retire un objectif.
  void toggleGoal(String value) {
    final next = {...state.goals};
    next.contains(value) ? next.remove(value) : next.add(value);
    state = state.copyWith(goals: next);
    _schedulePersist();
  }

  /// Met à jour l'étape courante du parcours (utilisé pour persister le
  /// progrès entre 0-2 avant navigation ou fermeture app).
  void setCurrentStep(int step) {
    if (step == state.currentStep) return;
    state = state.copyWith(currentStep: step);
    _schedulePersist();
  }

  /// Planifie la persistance debouncée (300 ms) du brouillon.
  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 300), _persistNow);
  }

  /// Sérialise immédiatement l'état courant dans SharedPreferences.
  Future<void> _persistNow() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final draft = state.toDraft();
    await prefs.setString(_draftKey, jsonEncode(draft.toJson()));
  }

  /// Indique si un brouillon est actuellement sauvegardé.
  Future<bool> hasDraft() async {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.containsKey(_draftKey);
  }

  /// Supprime le brouillon après complétion ou annulation explicite.
  Future<void> clearDraft() async {
    _persistTimer?.cancel();
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_draftKey);
  }

  /// Force la synchronisation immédiate (utile avant navigation).
  Future<void> flush() async {
    _persistTimer?.cancel();
    await _persistNow();
  }

  /// Réinitialise complètement l'état et supprime le brouillon.
  Future<void> reset() async {
    await clearDraft();
    state = const OnboardingState();
  }
}

/// Provider Riverpod pour l'état et le notifier d'onboarding.
final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
