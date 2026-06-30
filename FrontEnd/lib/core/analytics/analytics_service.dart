import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_events.dart';
import 'event_payload.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return const AnalyticsService();
});

class AnalyticsService {
  const AnalyticsService();

  void track(String name, [Map<String, Object?> properties = const {}]) {
    debugPrint('analytics:$name $properties');
  }

  Future<void> trackPayload(String name, {EventPayload? payload}) async {
    track(name, {
      if (payload != null)
        'userId': payload.userId,
      if (payload != null)
        'planMode': payload.planMode,
      if (payload != null)
        'planDurationDays': payload.planDurationDays,
      if (payload != null)
        'householdSize': payload.householdSize,
      if (payload != null)
        'weeklyBudget': payload.weeklyBudget,
      if (payload != null)
        'locale': payload.locale,
      if (payload != null)
        'source': payload.source,
      if (payload != null && payload.meta.isNotEmpty)
        'meta': payload.meta,
    });
  }

  void trackOnboardingStarted() =>
      track(PlateEvents.onboardingStarted);
  void trackOnboardingCompleted() =>
      track(PlateEvents.onboardingCompleted);
  void trackOnboardingSkipped() =>
      track(PlateEvents.onboardingSkipped);

  void trackOnboardingStep1() =>
      track(PlateEvents.onboardingStep1Household);
  void trackOnboardingStep2() =>
      track(PlateEvents.onboardingStep2Budget);
  void trackOnboardingStep3() =>
      track(PlateEvents.onboardingStep3Dietary);
  void trackOnboardingStep4() =>
      track(PlateEvents.onboardingStep4Allergies);

  void trackPlanGenerated({EventPayload? payload}) =>
      trackPayload(PlateEvents.planGenerated, payload: payload);
  void trackPlanRegenerated({EventPayload? payload}) =>
      trackPayload(PlateEvents.planRegenerated, payload: payload);
  void trackPlanActivated({EventPayload? payload}) =>
      trackPayload(PlateEvents.planActivated, payload: payload);
  void trackFilterApplied({EventPayload? payload}) =>
      trackPayload(PlateEvents.filterApplied, payload: payload);

  void trackGroceryListGenerated({EventPayload? payload}) =>
      trackPayload(PlateEvents.groceryListGenerated, payload: payload);
  void trackGroceryItemChecked({EventPayload? payload}) =>
      trackPayload(PlateEvents.groceryItemChecked, payload: payload);
  void trackGroceryListExported({EventPayload? payload}) =>
      trackPayload(PlateEvents.groceryListExported, payload: payload);
  void trackGroceryListShared({EventPayload? payload}) =>
      trackPayload(PlateEvents.groceryListShared, payload: payload);

  void trackMealSwapped({EventPayload? payload}) =>
      trackPayload(PlateEvents.mealSwapped, payload: payload);

  void trackPantryItemAdded({EventPayload? payload}) =>
      trackPayload(PlateEvents.pantryItemAdded, payload: payload);
  void trackPantryItemRemoved({EventPayload? payload}) =>
      trackPayload(PlateEvents.pantryItemRemoved, payload: payload);
  void trackPantryItemConsumed({EventPayload? payload}) =>
      trackPayload(PlateEvents.pantryItemConsumed, payload: payload);

  void trackSignupCompleted({EventPayload? payload}) =>
      trackPayload(PlateEvents.signupCompleted, payload: payload);
  void trackLoginCompleted({EventPayload? payload}) =>
      trackPayload(PlateEvents.loginCompleted, payload: payload);
  void trackEmailVerified({EventPayload? payload}) =>
      trackPayload(PlateEvents.emailVerified, payload: payload);
  void trackLogoutCompleted({EventPayload? payload}) =>
      trackPayload(PlateEvents.logoutCompleted, payload: payload);

  void trackUpgradeScreenViewed({EventPayload? payload}) =>
      trackPayload(PlateEvents.upgradeScreenViewed, payload: payload);
  void trackCheckoutStarted({EventPayload? payload}) =>
      trackPayload(PlateEvents.checkoutStarted, payload: payload);
  void trackCheckoutCompleted({EventPayload? payload}) =>
      trackPayload(PlateEvents.checkoutCompleted, payload: payload);
  void trackCheckoutCancelled({EventPayload? payload}) =>
      trackPayload(PlateEvents.checkoutCancelled, payload: payload);
}
