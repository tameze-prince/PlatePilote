import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_payload.freezed.dart';

@freezed
sealed class EventPayload with _$EventPayload {
  const factory EventPayload({
    @Default('') String userId,
    @Default('') String planMode,
    @Default(0) int planDurationDays,
    @Default(0) int householdSize,
    @Default(0.0) double weeklyBudget,
    @Default('') String locale,
    @Default('') String source,
    @Default(<String, Object>{}) Map<String, Object> meta,
  }) = _EventPayload;
}
