import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionState {
  const SubscriptionState({
    this.isPremium = false,
    this.planName = 'Free',
    this.paymentMethod = 'No payment method',
  });

  final bool isPremium;
  final String planName;
  final String paymentMethod;

  SubscriptionState copyWith({
    bool? isPremium,
    String? planName,
    String? paymentMethod,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      planName: planName ?? this.planName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => const SubscriptionState();

  void startTrial() {
    state = state.copyWith(isPremium: true, planName: 'Premium Trial');
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
      SubscriptionNotifier.new,
    );
