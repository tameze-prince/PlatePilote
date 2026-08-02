// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EventPayload {
  String get userId => throw _privateConstructorUsedError;
  String get planMode => throw _privateConstructorUsedError;
  int get planDurationDays => throw _privateConstructorUsedError;
  int get householdSize => throw _privateConstructorUsedError;
  double get weeklyBudget => throw _privateConstructorUsedError;
  String get locale => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  Map<String, Object> get meta => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EventPayloadCopyWith<EventPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventPayloadCopyWith<$Res> {
  factory $EventPayloadCopyWith(
          EventPayload value, $Res Function(EventPayload) then) =
      _$EventPayloadCopyWithImpl<$Res, EventPayload>;
  @useResult
  $Res call(
      {String userId,
      String planMode,
      int planDurationDays,
      int householdSize,
      double weeklyBudget,
      String locale,
      String source,
      Map<String, Object> meta});
}

/// @nodoc
class _$EventPayloadCopyWithImpl<$Res, $Val extends EventPayload>
    implements $EventPayloadCopyWith<$Res> {
  _$EventPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? planMode = null,
    Object? planDurationDays = null,
    Object? householdSize = null,
    Object? weeklyBudget = null,
    Object? locale = null,
    Object? source = null,
    Object? meta = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      planMode: null == planMode
          ? _value.planMode
          : planMode // ignore: cast_nullable_to_non_nullable
              as String,
      planDurationDays: null == planDurationDays
          ? _value.planDurationDays
          : planDurationDays // ignore: cast_nullable_to_non_nullable
              as int,
      householdSize: null == householdSize
          ? _value.householdSize
          : householdSize // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyBudget: null == weeklyBudget
          ? _value.weeklyBudget
          : weeklyBudget // ignore: cast_nullable_to_non_nullable
              as double,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      meta: null == meta
          ? _value.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Map<String, Object>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventPayloadImplCopyWith<$Res>
    implements $EventPayloadCopyWith<$Res> {
  factory _$$EventPayloadImplCopyWith(
          _$EventPayloadImpl value, $Res Function(_$EventPayloadImpl) then) =
      __$$EventPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String planMode,
      int planDurationDays,
      int householdSize,
      double weeklyBudget,
      String locale,
      String source,
      Map<String, Object> meta});
}

/// @nodoc
class __$$EventPayloadImplCopyWithImpl<$Res>
    extends _$EventPayloadCopyWithImpl<$Res, _$EventPayloadImpl>
    implements _$$EventPayloadImplCopyWith<$Res> {
  __$$EventPayloadImplCopyWithImpl(
      _$EventPayloadImpl _value, $Res Function(_$EventPayloadImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? planMode = null,
    Object? planDurationDays = null,
    Object? householdSize = null,
    Object? weeklyBudget = null,
    Object? locale = null,
    Object? source = null,
    Object? meta = null,
  }) {
    return _then(_$EventPayloadImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      planMode: null == planMode
          ? _value.planMode
          : planMode // ignore: cast_nullable_to_non_nullable
              as String,
      planDurationDays: null == planDurationDays
          ? _value.planDurationDays
          : planDurationDays // ignore: cast_nullable_to_non_nullable
              as int,
      householdSize: null == householdSize
          ? _value.householdSize
          : householdSize // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyBudget: null == weeklyBudget
          ? _value.weeklyBudget
          : weeklyBudget // ignore: cast_nullable_to_non_nullable
              as double,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      meta: null == meta
          ? _value._meta
          : meta // ignore: cast_nullable_to_non_nullable
              as Map<String, Object>,
    ));
  }
}

/// @nodoc

class _$EventPayloadImpl implements _EventPayload {
  const _$EventPayloadImpl(
      {this.userId = '',
      this.planMode = '',
      this.planDurationDays = 0,
      this.householdSize = 0,
      this.weeklyBudget = 0.0,
      this.locale = '',
      this.source = '',
      final Map<String, Object> meta = const <String, Object>{}})
      : _meta = meta;

  @override
  @JsonKey()
  final String userId;
  @override
  @JsonKey()
  final String planMode;
  @override
  @JsonKey()
  final int planDurationDays;
  @override
  @JsonKey()
  final int householdSize;
  @override
  @JsonKey()
  final double weeklyBudget;
  @override
  @JsonKey()
  final String locale;
  @override
  @JsonKey()
  final String source;
  final Map<String, Object> _meta;
  @override
  @JsonKey()
  Map<String, Object> get meta {
    if (_meta is EqualUnmodifiableMapView) return _meta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_meta);
  }

  @override
  String toString() {
    return 'EventPayload(userId: $userId, planMode: $planMode, planDurationDays: $planDurationDays, householdSize: $householdSize, weeklyBudget: $weeklyBudget, locale: $locale, source: $source, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventPayloadImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.planMode, planMode) ||
                other.planMode == planMode) &&
            (identical(other.planDurationDays, planDurationDays) ||
                other.planDurationDays == planDurationDays) &&
            (identical(other.householdSize, householdSize) ||
                other.householdSize == householdSize) &&
            (identical(other.weeklyBudget, weeklyBudget) ||
                other.weeklyBudget == weeklyBudget) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other._meta, _meta));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      planMode,
      planDurationDays,
      householdSize,
      weeklyBudget,
      locale,
      source,
      const DeepCollectionEquality().hash(_meta));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventPayloadImplCopyWith<_$EventPayloadImpl> get copyWith =>
      __$$EventPayloadImplCopyWithImpl<_$EventPayloadImpl>(this, _$identity);
}

abstract class _EventPayload implements EventPayload {
  const factory _EventPayload(
      {final String userId,
      final String planMode,
      final int planDurationDays,
      final int householdSize,
      final double weeklyBudget,
      final String locale,
      final String source,
      final Map<String, Object> meta}) = _$EventPayloadImpl;

  @override
  String get userId;
  @override
  String get planMode;
  @override
  int get planDurationDays;
  @override
  int get householdSize;
  @override
  double get weeklyBudget;
  @override
  String get locale;
  @override
  String get source;
  @override
  Map<String, Object> get meta;
  @override
  @JsonKey(ignore: true)
  _$$EventPayloadImplCopyWith<_$EventPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
