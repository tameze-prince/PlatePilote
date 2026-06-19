import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

/// État de l'abonnement utilisateur.
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

  /// Vrai si le chargement est en cours.
  final bool isLoading;
  /// Vrai si l'utilisateur est Premium.
  final bool isPremium;
  /// Nom du plan (FREE, PREMIUM, etc.).
  final String planName;
  /// Statut de l'abonnement.
  final String? status;
  /// Date de fin d'essai.
  final String? trialEndDate;
  /// Vrai si l'abonnement est résilié en fin de période.
  final bool cancelAtPeriodEnd;
  /// Message d'erreur éventuel.
  final String? errorMessage;

  /// Retourne une copie avec les champs modifiés.
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

/// Notifier qui gère l'état de l'abonnement.
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    Future.microtask(() => _loadSubscription());
    return const SubscriptionState();
  }

  /// Charge les données d'abonnement depuis l'API.
  Future<void> _loadSubscription() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/subscription');
      final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;

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

  /// Crée une session de checkout Stripe et retourne l'URL.
  Future<String?> createCheckoutSession() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/billing/stripe/checkout-session',
        data: {'plan': 'MONTHLY'},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return data['url'] as String?;
    } on DioException {
      return null;
    }
  }

  /// Crée un portail client Stripe et retourne l'URL.
  Future<String?> createCustomerPortal() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/billing/stripe/customer-portal');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return data['url'] as String?;
    } on DioException {
      return null;
    }
  }

  /// Recharge les données d'abonnement.
  Future<void> refresh() => _loadSubscription();
}

/// Provider Riverpod pour l'abonnement.
final subscriptionProvider = NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
