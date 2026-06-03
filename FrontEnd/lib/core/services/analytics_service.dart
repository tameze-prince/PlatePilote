import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider Riverpod pour [AnalyticsService].
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return const AnalyticsService();
});

/// Service d'analyse d'événements.
/// Actuellement, les événements sont simplement loggés en debug.
class AnalyticsService {
  const AnalyticsService();

  /// Enregistre un événement d'analyse avec des propriétés optionnelles.
  void track(String event, [Map<String, Object?> properties = const {}]) {
    debugPrint('analytics:$event $properties');
  }
}
