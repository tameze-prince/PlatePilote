import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../meal_plan/meal_plan_provider.dart';

class OnboardingCompletion {
  const OnboardingCompletion._();

  static Future<void> commitAndGeneratePlan({
    required WidgetRef ref,
    required BuildContext context,
    required VoidCallback onSuccess,
  }) async {
    try {
      await ref.read(mealPlanProvider.notifier).generateNewPlan();
    } catch (_) {
      // Erreur backend toleree : on accepte la transition UI pour ne pas
      // bloquer l'utilisateur dans l'onboarding (l'app retente ensuite).
    }
    if (context.mounted) {
      onSuccess();
    }
  }
}
