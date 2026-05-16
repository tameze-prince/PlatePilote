import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hapticServiceProvider = Provider<HapticService>((ref) {
  return const HapticService();
});

class HapticService {
  const HapticService();

  Future<void> selection() => HapticFeedback.selectionClick();
  Future<void> success() => HapticFeedback.lightImpact();
  Future<void> warning() => HapticFeedback.mediumImpact();
}
