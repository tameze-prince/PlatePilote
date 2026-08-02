// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OnboardingDraftImpl _$$OnboardingDraftImplFromJson(
        Map<String, dynamic> json) =>
    _$OnboardingDraftImpl(
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      completedSteps: (json['completedSteps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      householdSize: json['householdSize'] as String?,
      cookingProfile: json['cookingProfile'] as String?,
      weeklyBudget: json['weeklyBudget'] as String?,
      customBudget: (json['customBudget'] as num?)?.toDouble(),
      cookingTime: json['cookingTime'] as String?,
      dietaryPreferences: (json['dietaryPreferences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      goals:
          (json['goals'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$OnboardingDraftImplToJson(
        _$OnboardingDraftImpl instance) =>
    <String, dynamic>{
      'currentStep': instance.currentStep,
      'completedSteps': instance.completedSteps,
      'householdSize': instance.householdSize,
      'cookingProfile': instance.cookingProfile,
      'weeklyBudget': instance.weeklyBudget,
      'customBudget': instance.customBudget,
      'cookingTime': instance.cookingTime,
      'dietaryPreferences': instance.dietaryPreferences,
      'goals': instance.goals,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
