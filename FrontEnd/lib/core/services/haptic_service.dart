import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider Riverpod pour [HapticService].
final hapticServiceProvider = Provider<HapticService>((ref) {
  return const HapticService();
});

/// Service de retour haptique (vibrations) pour les interactions utilisateur.
class HapticService {
  const HapticService();

  /// Retour haptique de sélection (clic léger).
  Future<void> selection() => HapticFeedback.selectionClick();

  /// Retour haptique de succès (impact léger).
  Future<void> success() => HapticFeedback.lightImpact();

  /// Retour haptique d'avertissement (impact moyen).
  Future<void> warning() => HapticFeedback.mediumImpact();
}
