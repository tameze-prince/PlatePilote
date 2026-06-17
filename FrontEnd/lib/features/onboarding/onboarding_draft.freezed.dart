// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingDraft {

 int get currentStep; List<String> get completedSteps; String? get householdSize;@JsonKey(name: 'cooking_profile') String? get cookingProfile; String? get weeklyBudget; double? get customBudget;@JsonKey(name: 'cooking_time') String? get cookingTime; List<String> get dietaryPreferences; List<String> get goals;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingDraftCopyWith<OnboardingDraft> get copyWith => _$OnboardingDraftCopyWithImpl<OnboardingDraft>(this as OnboardingDraft, _$identity);

  /// Serializes this OnboardingDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingDraft&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&const DeepCollectionEquality().equals(other.completedSteps, completedSteps)&&(identical(other.householdSize, householdSize) || other.householdSize == householdSize)&&(identical(other.cookingProfile, cookingProfile) || other.cookingProfile == cookingProfile)&&(identical(other.weeklyBudget, weeklyBudget) || other.weeklyBudget == weeklyBudget)&&(identical(other.customBudget, customBudget) || other.customBudget == customBudget)&&(identical(other.cookingTime, cookingTime) || other.cookingTime == cookingTime)&&const DeepCollectionEquality().equals(other.dietaryPreferences, dietaryPreferences)&&const DeepCollectionEquality().equals(other.goals, goals)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStep,const DeepCollectionEquality().hash(completedSteps),householdSize,cookingProfile,weeklyBudget,customBudget,cookingTime,const DeepCollectionEquality().hash(dietaryPreferences),const DeepCollectionEquality().hash(goals),updatedAt);

@override
String toString() {
  return 'OnboardingDraft(currentStep: $currentStep, completedSteps: $completedSteps, householdSize: $householdSize, cookingProfile: $cookingProfile, weeklyBudget: $weeklyBudget, customBudget: $customBudget, cookingTime: $cookingTime, dietaryPreferences: $dietaryPreferences, goals: $goals, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OnboardingDraftCopyWith<$Res>  {
  factory $OnboardingDraftCopyWith(OnboardingDraft value, $Res Function(OnboardingDraft) _then) = _$OnboardingDraftCopyWithImpl;
@useResult
$Res call({
 int currentStep, List<String> completedSteps, String? householdSize,@JsonKey(name: 'cooking_profile') String? cookingProfile, String? weeklyBudget, double? customBudget,@JsonKey(name: 'cooking_time') String? cookingTime, List<String> dietaryPreferences, List<String> goals,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$OnboardingDraftCopyWithImpl<$Res>
    implements $OnboardingDraftCopyWith<$Res> {
  _$OnboardingDraftCopyWithImpl(this._self, this._then);

  final OnboardingDraft _self;
  final $Res Function(OnboardingDraft) _then;

/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? completedSteps = null,Object? householdSize = freezed,Object? cookingProfile = freezed,Object? weeklyBudget = freezed,Object? customBudget = freezed,Object? cookingTime = freezed,Object? dietaryPreferences = null,Object? goals = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,completedSteps: null == completedSteps ? _self.completedSteps : completedSteps // ignore: cast_nullable_to_non_nullable
as List<String>,householdSize: freezed == householdSize ? _self.householdSize : householdSize // ignore: cast_nullable_to_non_nullable
as String?,cookingProfile: freezed == cookingProfile ? _self.cookingProfile : cookingProfile // ignore: cast_nullable_to_non_nullable
as String?,weeklyBudget: freezed == weeklyBudget ? _self.weeklyBudget : weeklyBudget // ignore: cast_nullable_to_non_nullable
as String?,customBudget: freezed == customBudget ? _self.customBudget : customBudget // ignore: cast_nullable_to_non_nullable
as double?,cookingTime: freezed == cookingTime ? _self.cookingTime : cookingTime // ignore: cast_nullable_to_non_nullable
as String?,dietaryPreferences: null == dietaryPreferences ? _self.dietaryPreferences : dietaryPreferences // ignore: cast_nullable_to_non_nullable
as List<String>,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingDraft].
extension OnboardingDraftPatterns on OnboardingDraft {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingDraft value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingDraft():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingDraft value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStep,  List<String> completedSteps,  String? householdSize, @JsonKey(name: 'cooking_profile')  String? cookingProfile,  String? weeklyBudget,  double? customBudget, @JsonKey(name: 'cooking_time')  String? cookingTime,  List<String> dietaryPreferences,  List<String> goals, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that.currentStep,_that.completedSteps,_that.householdSize,_that.cookingProfile,_that.weeklyBudget,_that.customBudget,_that.cookingTime,_that.dietaryPreferences,_that.goals,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStep,  List<String> completedSteps,  String? householdSize, @JsonKey(name: 'cooking_profile')  String? cookingProfile,  String? weeklyBudget,  double? customBudget, @JsonKey(name: 'cooking_time')  String? cookingTime,  List<String> dietaryPreferences,  List<String> goals, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OnboardingDraft():
return $default(_that.currentStep,_that.completedSteps,_that.householdSize,_that.cookingProfile,_that.weeklyBudget,_that.customBudget,_that.cookingTime,_that.dietaryPreferences,_that.goals,_that.updatedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStep,  List<String> completedSteps,  String? householdSize, @JsonKey(name: 'cooking_profile')  String? cookingProfile,  String? weeklyBudget,  double? customBudget, @JsonKey(name: 'cooking_time')  String? cookingTime,  List<String> dietaryPreferences,  List<String> goals, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that.currentStep,_that.completedSteps,_that.householdSize,_that.cookingProfile,_that.weeklyBudget,_that.customBudget,_that.cookingTime,_that.dietaryPreferences,_that.goals,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingDraft implements OnboardingDraft {
  const _OnboardingDraft({this.currentStep = 0, final  List<String> completedSteps = const <String>[], this.householdSize, @JsonKey(name: 'cooking_profile') this.cookingProfile, this.weeklyBudget, this.customBudget, @JsonKey(name: 'cooking_time') this.cookingTime, final  List<String> dietaryPreferences = const <String>[], final  List<String> goals = const <String>[], @JsonKey(name: 'updated_at') this.updatedAt}): _completedSteps = completedSteps,_dietaryPreferences = dietaryPreferences,_goals = goals;
  factory _OnboardingDraft.fromJson(Map<String, dynamic> json) => _$OnboardingDraftFromJson(json);

@override@JsonKey() final  int currentStep;
 final  List<String> _completedSteps;
@override@JsonKey() List<String> get completedSteps {
  if (_completedSteps is EqualUnmodifiableListView) return _completedSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedSteps);
}

@override final  String? householdSize;
@override@JsonKey(name: 'cooking_profile') final  String? cookingProfile;
@override final  String? weeklyBudget;
@override final  double? customBudget;
@override@JsonKey(name: 'cooking_time') final  String? cookingTime;
 final  List<String> _dietaryPreferences;
@override@JsonKey() List<String> get dietaryPreferences {
  if (_dietaryPreferences is EqualUnmodifiableListView) return _dietaryPreferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dietaryPreferences);
}

 final  List<String> _goals;
@override@JsonKey() List<String> get goals {
  if (_goals is EqualUnmodifiableListView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goals);
}

@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingDraftCopyWith<_OnboardingDraft> get copyWith => __$OnboardingDraftCopyWithImpl<_OnboardingDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingDraft&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&const DeepCollectionEquality().equals(other._completedSteps, _completedSteps)&&(identical(other.householdSize, householdSize) || other.householdSize == householdSize)&&(identical(other.cookingProfile, cookingProfile) || other.cookingProfile == cookingProfile)&&(identical(other.weeklyBudget, weeklyBudget) || other.weeklyBudget == weeklyBudget)&&(identical(other.customBudget, customBudget) || other.customBudget == customBudget)&&(identical(other.cookingTime, cookingTime) || other.cookingTime == cookingTime)&&const DeepCollectionEquality().equals(other._dietaryPreferences, _dietaryPreferences)&&const DeepCollectionEquality().equals(other._goals, _goals)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStep,const DeepCollectionEquality().hash(_completedSteps),householdSize,cookingProfile,weeklyBudget,customBudget,cookingTime,const DeepCollectionEquality().hash(_dietaryPreferences),const DeepCollectionEquality().hash(_goals),updatedAt);

@override
String toString() {
  return 'OnboardingDraft(currentStep: $currentStep, completedSteps: $completedSteps, householdSize: $householdSize, cookingProfile: $cookingProfile, weeklyBudget: $weeklyBudget, customBudget: $customBudget, cookingTime: $cookingTime, dietaryPreferences: $dietaryPreferences, goals: $goals, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OnboardingDraftCopyWith<$Res> implements $OnboardingDraftCopyWith<$Res> {
  factory _$OnboardingDraftCopyWith(_OnboardingDraft value, $Res Function(_OnboardingDraft) _then) = __$OnboardingDraftCopyWithImpl;
@override @useResult
$Res call({
 int currentStep, List<String> completedSteps, String? householdSize,@JsonKey(name: 'cooking_profile') String? cookingProfile, String? weeklyBudget, double? customBudget,@JsonKey(name: 'cooking_time') String? cookingTime, List<String> dietaryPreferences, List<String> goals,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$OnboardingDraftCopyWithImpl<$Res>
    implements _$OnboardingDraftCopyWith<$Res> {
  __$OnboardingDraftCopyWithImpl(this._self, this._then);

  final _OnboardingDraft _self;
  final $Res Function(_OnboardingDraft) _then;

/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? completedSteps = null,Object? householdSize = freezed,Object? cookingProfile = freezed,Object? weeklyBudget = freezed,Object? customBudget = freezed,Object? cookingTime = freezed,Object? dietaryPreferences = null,Object? goals = null,Object? updatedAt = freezed,}) {
  return _then(_OnboardingDraft(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,completedSteps: null == completedSteps ? _self._completedSteps : completedSteps // ignore: cast_nullable_to_non_nullable
as List<String>,householdSize: freezed == householdSize ? _self.householdSize : householdSize // ignore: cast_nullable_to_non_nullable
as String?,cookingProfile: freezed == cookingProfile ? _self.cookingProfile : cookingProfile // ignore: cast_nullable_to_non_nullable
as String?,weeklyBudget: freezed == weeklyBudget ? _self.weeklyBudget : weeklyBudget // ignore: cast_nullable_to_non_nullable
as String?,customBudget: freezed == customBudget ? _self.customBudget : customBudget // ignore: cast_nullable_to_non_nullable
as double?,cookingTime: freezed == cookingTime ? _self.cookingTime : cookingTime // ignore: cast_nullable_to_non_nullable
as String?,dietaryPreferences: null == dietaryPreferences ? _self._dietaryPreferences : dietaryPreferences // ignore: cast_nullable_to_non_nullable
as List<String>,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
