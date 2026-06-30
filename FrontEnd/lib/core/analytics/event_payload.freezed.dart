// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventPayload {

 String get userId; String get planMode; int get planDurationDays; int get householdSize; double get weeklyBudget; String get locale; String get source; Map<String, Object> get meta;
/// Create a copy of EventPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventPayloadCopyWith<EventPayload> get copyWith => _$EventPayloadCopyWithImpl<EventPayload>(this as EventPayload, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventPayload&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.planMode, planMode) || other.planMode == planMode)&&(identical(other.planDurationDays, planDurationDays) || other.planDurationDays == planDurationDays)&&(identical(other.householdSize, householdSize) || other.householdSize == householdSize)&&(identical(other.weeklyBudget, weeklyBudget) || other.weeklyBudget == weeklyBudget)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.meta, meta));
}


@override
int get hashCode => Object.hash(runtimeType,userId,planMode,planDurationDays,householdSize,weeklyBudget,locale,source,const DeepCollectionEquality().hash(meta));

@override
String toString() {
  return 'EventPayload(userId: $userId, planMode: $planMode, planDurationDays: $planDurationDays, householdSize: $householdSize, weeklyBudget: $weeklyBudget, locale: $locale, source: $source, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $EventPayloadCopyWith<$Res>  {
  factory $EventPayloadCopyWith(EventPayload value, $Res Function(EventPayload) _then) = _$EventPayloadCopyWithImpl;
@useResult
$Res call({
 String userId, String planMode, int planDurationDays, int householdSize, double weeklyBudget, String locale, String source, Map<String, Object> meta
});




}
/// @nodoc
class _$EventPayloadCopyWithImpl<$Res>
    implements $EventPayloadCopyWith<$Res> {
  _$EventPayloadCopyWithImpl(this._self, this._then);

  final EventPayload _self;
  final $Res Function(EventPayload) _then;

/// Create a copy of EventPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? planMode = null,Object? planDurationDays = null,Object? householdSize = null,Object? weeklyBudget = null,Object? locale = null,Object? source = null,Object? meta = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,planMode: null == planMode ? _self.planMode : planMode // ignore: cast_nullable_to_non_nullable
as String,planDurationDays: null == planDurationDays ? _self.planDurationDays : planDurationDays // ignore: cast_nullable_to_non_nullable
as int,householdSize: null == householdSize ? _self.householdSize : householdSize // ignore: cast_nullable_to_non_nullable
as int,weeklyBudget: null == weeklyBudget ? _self.weeklyBudget : weeklyBudget // ignore: cast_nullable_to_non_nullable
as double,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, Object>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventPayload].
extension EventPayloadPatterns on EventPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventPayload value)  $default,){
final _that = this;
switch (_that) {
case _EventPayload():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventPayload value)?  $default,){
final _that = this;
switch (_that) {
case _EventPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String planMode,  int planDurationDays,  int householdSize,  double weeklyBudget,  String locale,  String source,  Map<String, Object> meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventPayload() when $default != null:
return $default(_that.userId,_that.planMode,_that.planDurationDays,_that.householdSize,_that.weeklyBudget,_that.locale,_that.source,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String planMode,  int planDurationDays,  int householdSize,  double weeklyBudget,  String locale,  String source,  Map<String, Object> meta)  $default,) {final _that = this;
switch (_that) {
case _EventPayload():
return $default(_that.userId,_that.planMode,_that.planDurationDays,_that.householdSize,_that.weeklyBudget,_that.locale,_that.source,_that.meta);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String planMode,  int planDurationDays,  int householdSize,  double weeklyBudget,  String locale,  String source,  Map<String, Object> meta)?  $default,) {final _that = this;
switch (_that) {
case _EventPayload() when $default != null:
return $default(_that.userId,_that.planMode,_that.planDurationDays,_that.householdSize,_that.weeklyBudget,_that.locale,_that.source,_that.meta);case _:
  return null;

}
}

}

/// @nodoc


class _EventPayload implements EventPayload {
  const _EventPayload({this.userId = '', this.planMode = '', this.planDurationDays = 0, this.householdSize = 0, this.weeklyBudget = 0.0, this.locale = '', this.source = '', final  Map<String, Object> meta = const <String, Object>{}}): _meta = meta;
  

@override@JsonKey() final  String userId;
@override@JsonKey() final  String planMode;
@override@JsonKey() final  int planDurationDays;
@override@JsonKey() final  int householdSize;
@override@JsonKey() final  double weeklyBudget;
@override@JsonKey() final  String locale;
@override@JsonKey() final  String source;
 final  Map<String, Object> _meta;
@override@JsonKey() Map<String, Object> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}


/// Create a copy of EventPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventPayloadCopyWith<_EventPayload> get copyWith => __$EventPayloadCopyWithImpl<_EventPayload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventPayload&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.planMode, planMode) || other.planMode == planMode)&&(identical(other.planDurationDays, planDurationDays) || other.planDurationDays == planDurationDays)&&(identical(other.householdSize, householdSize) || other.householdSize == householdSize)&&(identical(other.weeklyBudget, weeklyBudget) || other.weeklyBudget == weeklyBudget)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other._meta, _meta));
}


@override
int get hashCode => Object.hash(runtimeType,userId,planMode,planDurationDays,householdSize,weeklyBudget,locale,source,const DeepCollectionEquality().hash(_meta));

@override
String toString() {
  return 'EventPayload(userId: $userId, planMode: $planMode, planDurationDays: $planDurationDays, householdSize: $householdSize, weeklyBudget: $weeklyBudget, locale: $locale, source: $source, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$EventPayloadCopyWith<$Res> implements $EventPayloadCopyWith<$Res> {
  factory _$EventPayloadCopyWith(_EventPayload value, $Res Function(_EventPayload) _then) = __$EventPayloadCopyWithImpl;
@override @useResult
$Res call({
 String userId, String planMode, int planDurationDays, int householdSize, double weeklyBudget, String locale, String source, Map<String, Object> meta
});




}
/// @nodoc
class __$EventPayloadCopyWithImpl<$Res>
    implements _$EventPayloadCopyWith<$Res> {
  __$EventPayloadCopyWithImpl(this._self, this._then);

  final _EventPayload _self;
  final $Res Function(_EventPayload) _then;

/// Create a copy of EventPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? planMode = null,Object? planDurationDays = null,Object? householdSize = null,Object? weeklyBudget = null,Object? locale = null,Object? source = null,Object? meta = null,}) {
  return _then(_EventPayload(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,planMode: null == planMode ? _self.planMode : planMode // ignore: cast_nullable_to_non_nullable
as String,planDurationDays: null == planDurationDays ? _self.planDurationDays : planDurationDays // ignore: cast_nullable_to_non_nullable
as int,householdSize: null == householdSize ? _self.householdSize : householdSize // ignore: cast_nullable_to_non_nullable
as int,weeklyBudget: null == weeklyBudget ? _self.weeklyBudget : weeklyBudget // ignore: cast_nullable_to_non_nullable
as double,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, Object>,
  ));
}


}

// dart format on
