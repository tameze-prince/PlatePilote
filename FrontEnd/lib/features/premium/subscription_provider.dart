import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

class SubscriptionState {
  const SubscriptionState({
    this.isLoading = true,
    this.isPremium = false,
    this.planName = 'FREE',
    this.status,
    this.trialEndDate,
    this.cancelAtPeriodEnd = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isPremium;
  final String planName;
  final String? status;
  final String? trialEndDate;
  final bool cancelAtPeriodEnd;
  final String? errorMessage;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isPremium,
    String? planName,
    String? status,
    String? trialEndDate,
    bool? cancelAtPeriodEnd,
    String? errorMessage,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isPremium: isPremium ?? this.isPremium,
      planName: planName ?? this.planName,
      status: status ?? this.status,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      cancelAtPeriodEnd: cancelAtPeriodEnd ?? this.cancelAtPeriodEnd,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    Future.microtask(() => _loadSubscription());
    return const SubscriptionState();
  }

  Future<void> _loadSubscription() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/subscription');
      final data = response.data['data'] as Map<String, dynamic>;

      final planType = data['planType'] as String? ?? 'FREE';
      state = SubscriptionState(
        isLoading: false,
        isPremium: planType == 'PREMIUM',
        planName: planType,
        status: data['status'] as String?,
        trialEndDate: data['trialEndDate'] as String?,
        cancelAtPeriodEnd: data['cancelAtPeriodEnd'] as bool? ?? false,
      );
    } on DioException {
      state = const SubscriptionState(isLoading: false);
    }
  }

  Future<String?> createCheckoutSession() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/billing/stripe/checkout-session',
        data: {'plan': 'PREMIUM_MONTHLY'},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return data['url'] as String?;
    } on DioException {
      return null;
    }
  }

  Future<String?> createCustomerPortal() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/billing/stripe/customer-portal');
      final data = response.data['data'] as Map<String, dynamic>;
      return data['url'] as String?;
    } on DioException {
      return null;
    }
  }

  Future<void> refresh() => _loadSubscription();
}

final subscriptionProvider = NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
