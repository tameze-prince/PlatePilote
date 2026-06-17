import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'explain_step.dart';
import 'payment_step.dart';
import 'pick_plan_step.dart';
import 'premium_funnel_provider.dart';

/// Écran hôte du funnel premium 3-étapes (Explain → PickPlan → Payment).
///
/// Utilise un `PageView` pour la navigation forward-only entre steps :
/// - Pas de pop possible entre étapes (garantit le funnel flow).
/// - L'utilisateur ne peut qu'avancer ou fermer l'écran via AppBar back.
/// - L'état du funnel est exposé via [premiumFunnelProvider].
class PremiumFunnelScreen extends ConsumerStatefulWidget {
  const PremiumFunnelScreen({super.key});

  @override
  ConsumerState<PremiumFunnelScreen> createState() =>
      _PremiumFunnelScreenState();
}

class _PremiumFunnelScreenState extends ConsumerState<PremiumFunnelScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Synchronise la position de la PageView avec l'étape courante du provider.
    ref.listen<PremiumFunnelState>(premiumFunnelProvider, (prev, next) {
      final prevIdx = _indexOf(prev?.currentStep);
      final nextIdx = _indexOf(next.currentStep);
      if (prevIdx != nextIdx && _pageController.hasClients) {
        _pageController.animateToPage(
          nextIdx,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          ExplainStep(),
          PickPlanStep(),
          PaymentStep(),
        ],
      ),
    );
  }

  int _indexOf(PremiumFunnelStep? step) {
    return switch (step) {
      PremiumFunnelStep.explain => 0,
      PremiumFunnelStep.pickPlan => 1,
      PremiumFunnelStep.payment => 2,
      null => 0,
    };
  }
}
