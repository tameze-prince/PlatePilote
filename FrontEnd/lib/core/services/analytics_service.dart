import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return const AnalyticsService();
});

class AnalyticsService {
  const AnalyticsService();

  void track(String event, [Map<String, Object?> properties = const {}]) {
    debugPrint('analytics:$event $properties');
  }
}
