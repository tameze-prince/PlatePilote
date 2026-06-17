import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_draft.freezed.dart';
part 'onboarding_draft.g.dart';

/// DTO persistant du parcours d'onboarding.
///
/// Stocké dans `SharedPreferences` sous la clé `pp.onboarding.draft.v1`
/// pour permettre à l'utilisateur de reprendre là où il s'était arrêté
/// après avoir quitté l'application (cf. audit UX §2).
@freezed
class OnboardingDraft with _$OnboardingDraft {
  /// Crée un brouillon avec des valeurs par défaut.
  const factory OnboardingDraft({
    @Default(0) int currentStep,
    @Default(<String>[]) List<String> completedSteps,
    String? householdSize,
    @JsonKey(name: 'cooking_profile') String? cookingProfile,
    String? weeklyBudget,
    double? customBudget,
    @JsonKey(name: 'cooking_time') String? cookingTime,
    @Default(<String>[]) List<String> dietaryPreferences,
    @Default(<String>[]) List<String> goals,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _OnboardingDraft;

  /// Construit un brouillon à partir d'un JSON.
  factory OnboardingDraft.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDraftFromJson(json);
}
