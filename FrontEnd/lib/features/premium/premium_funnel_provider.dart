import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Étape actuelle du funnel premium.
enum PremiumFunnelStep { explain, pickPlan, payment }

/// Choix de plan dans le funnel (étape 2).
enum PlanChoice { monthly, annual }

/// Méthode de paiement sélectionnée (étape 3).
enum PaymentMethod { applePay, googlePay, card }

/// État du funnel premium — étape courante + sélections utilisateur.
class PremiumFunnelState {
  const PremiumFunnelState({
    this.currentStep = PremiumFunnelStep.explain,
    this.planChoice = PlanChoice.annual,
    this.paymentMethod = PaymentMethod.applePay,
  });

  /// Étape courante (0 = Explain, 1 = PickPlan, 2 = Payment).
  final PremiumFunnelStep currentStep;

  /// Plan choisi (par défaut annual = plan recommandé).
  final PlanChoice planChoice;

  /// Méthode de paiement sélectionnée.
  final PaymentMethod paymentMethod;

  PremiumFunnelState copyWith({
    PremiumFunnelStep? currentStep,
    PlanChoice? planChoice,
    PaymentMethod? paymentMethod,
  }) {
    return PremiumFunnelState(
      currentStep: currentStep ?? this.currentStep,
      planChoice: planChoice ?? this.planChoice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

/// Notifier Riverpod gérant l'état éphémère du funnel.
///
/// On ne persiste PAS ces infos — c'est de l'état UI volatil qui disparaît
/// dès que l'utilisateur quitte le funnel.
class PremiumFunnelNotifier extends Notifier<PremiumFunnelState> {
  @override
  PremiumFunnelState build() => const PremiumFunnelState();

  /// Avance à l'étape suivante si possible.
  void next() {
    final s = state.currentStep;
    if (s == PremiumFunnelStep.explain) {
      state = state.copyWith(currentStep: PremiumFunnelStep.pickPlan);
    } else if (s == PremiumFunnelStep.pickPlan) {
      state = state.copyWith(currentStep: PremiumFunnelStep.payment);
    }
  }

  /// Sélectionne Monthly ou Annual.
  void selectPlan(PlanChoice plan) {
    state = state.copyWith(planChoice: plan);
  }

  /// Sélectionne la méthode de paiement.
  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  /// Reset (utile si l'utilisateur pop depuis `/premium-funnel` puis revient).
  void reset() {
    state = const PremiumFunnelState();
  }
}

/// Provider Riverpod de l'état du funnel premium.
final premiumFunnelProvider =
    NotifierProvider<PremiumFunnelNotifier, PremiumFunnelState>(
  PremiumFunnelNotifier.new,
);
