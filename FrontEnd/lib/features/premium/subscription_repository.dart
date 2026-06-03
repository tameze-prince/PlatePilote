import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_provider.dart';

/// Provider pour [SubscriptionRepository].
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref);
});

/// Repository de l'abonnement utilisateur.
class SubscriptionRepository {
  const SubscriptionRepository(this._ref);

  /// Référence Riverpod.
  final Ref _ref;

  /// Lit l'état actuel de l'abonnement.
  SubscriptionState read() => _ref.read(subscriptionProvider);

  /// Recharge les données d'abonnement.
  Future<void> refresh() => _ref.read(subscriptionProvider.notifier).refresh();
}
