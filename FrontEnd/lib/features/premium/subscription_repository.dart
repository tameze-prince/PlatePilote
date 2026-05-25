import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_provider.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref);
});

class SubscriptionRepository {
  const SubscriptionRepository(this._ref);

  final Ref _ref;

  SubscriptionState read() => _ref.read(subscriptionProvider);
  Future<void> refresh() => _ref.read(subscriptionProvider.notifier).refresh();
}
