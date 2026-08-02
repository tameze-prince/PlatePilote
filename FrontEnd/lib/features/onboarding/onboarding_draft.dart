import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_draft.freezed.dart';
part 'onboarding_draft.g.dart';

/// DTO persistant du parcours d'onboarding.
///
/// Stocké dans `SharedPreferences` sous la clé `pp.onboarding.draft.v1`
/// pour permettre à l'utilisateur de reprendre là où il s'était arrêté
/// après avoir quitté l'application (cf. audit UX §2).
@freezed
sealed class OnboardingDraft with _$OnboardingDraft {
  /// Crée un brouillon avec des valeurs par défaut.
  const factory OnboardingDraft({
    @Default(0) int currentStep,
    @Default(<String>[]) List<String> completedSteps,
    String? householdSize,
    String? cookingProfile,
    String? weeklyBudget,
    double? customBudget,
    String? cookingTime,
    @Default(<String>[]) List<String> dietaryPreferences,
    @Default(<String>[]) List<String> goals,
    DateTime? updatedAt,
  }) = _OnboardingDraft;

  /// Construit un brouillon à partir d'un JSON.
  factory OnboardingDraft.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDraftFromJson(json);
}
