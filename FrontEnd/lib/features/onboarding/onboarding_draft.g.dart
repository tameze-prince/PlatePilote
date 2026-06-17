// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingDraft _$OnboardingDraftFromJson(Map<String, dynamic> json) =>
    _OnboardingDraft(
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      completedSteps:
          (json['completedSteps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      householdSize: json['householdSize'] as String?,
      cookingProfile: json['cooking_profile'] as String?,
      weeklyBudget: json['weeklyBudget'] as String?,
      customBudget: (json['customBudget'] as num?)?.toDouble(),
      cookingTime: json['cooking_time'] as String?,
      dietaryPreferences:
          (json['dietaryPreferences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      goals:
          (json['goals'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$OnboardingDraftToJson(_OnboardingDraft instance) =>
    <String, dynamic>{
      'currentStep': instance.currentStep,
      'completedSteps': instance.completedSteps,
      'householdSize': instance.householdSize,
      'cooking_profile': instance.cookingProfile,
      'weeklyBudget': instance.weeklyBudget,
      'customBudget': instance.customBudget,
      'cooking_time': instance.cookingTime,
      'dietaryPreferences': instance.dietaryPreferences,
      'goals': instance.goals,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
