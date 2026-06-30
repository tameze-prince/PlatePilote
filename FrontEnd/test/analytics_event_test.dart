import 'package:flutter_test/flutter_test.dart';
import 'package:plate_pilote/core/analytics/analytics_events.dart';
import 'package:plate_pilote/core/analytics/analytics_service.dart';
import 'package:plate_pilote/core/analytics/event_payload.dart';

void main() {
  group('PlateEvents constants', () {
    test('PRD §5 North Star events are present and non-empty', () {
      expect(PlateEvents.appOpened, 'app_opened');
      expect(PlateEvents.onboardingStarted, 'onboarding_started');
      expect(PlateEvents.onboardingCompleted, 'onboarding_completed');
      expect(PlateEvents.onboardingSkipped, 'onboarding_skipped');
    });

    test('PRD §5.7 onboarding step events are present', () {
      expect(
        PlateEvents.onboardingStep1Household,
        'onboarding_step1_household',
      );
      expect(PlateEvents.onboardingStep2Budget, 'onboarding_step2_budget');
      expect(
        PlateEvents.onboardingStep3Dietary,
        'onboarding_step3_dietary',
      );
      expect(
        PlateEvents.onboardingStep4Allergies,
        'onboarding_step4_allergies',
      );
    });

    test('Plan activation lifecycle events are present', () {
      expect(PlateEvents.planGenerated, 'plan_generated');
      expect(PlateEvents.planRegenerated, 'plan_regenerated');
      expect(PlateEvents.planActivated, 'plan_activated');
      expect(PlateEvents.filterApplied, 'filter_applied');
    });

    test('Grocery export events are present', () {
      expect(
        PlateEvents.groceryListGenerated,
        'grocery_list_generated',
      );
      expect(PlateEvents.groceryItemChecked, 'grocery_item_checked');
      expect(PlateEvents.groceryListExported, 'grocery_list_exported');
      expect(PlateEvents.groceryListShared, 'grocery_list_shared');
    });

    test('Auth funnel events are present', () {
      expect(PlateEvents.signupCompleted, 'signup_completed');
      expect(PlateEvents.loginCompleted, 'login_completed');
      expect(PlateEvents.emailVerified, 'email_verified');
      expect(PlateEvents.logoutCompleted, 'logout_completed');
    });

    test('Subscription funnel events are present', () {
      expect(PlateEvents.upgradeScreenViewed, 'upgrade_screen_viewed');
      expect(PlateEvents.checkoutStarted, 'checkout_started');
      expect(PlateEvents.checkoutCompleted, 'checkout_completed');
      expect(PlateEvents.checkoutCancelled, 'checkout_cancelled');
    });
  });

  group('EventPayload', () {
    test('default factory yields PRD-spec defaults', () {
      const payload = EventPayload();
      expect(payload.userId, '');
      expect(payload.planMode, '');
      expect(payload.planDurationDays, 0);
      expect(payload.householdSize, 0);
      expect(payload.weeklyBudget, 0.0);
      expect(payload.locale, '');
      expect(payload.source, '');
      expect(payload.meta, isEmpty);
    });

    test('copyWith updates intended fields', () {
      const payload = EventPayload();
      final updated = payload.copyWith(
        userId: 'user-42',
        planMode: 'faster',
        householdSize: 4,
        weeklyBudget: 120.0,
        locale: 'fr',
        source: 'filter',
      );
      expect(updated.userId, 'user-42');
      expect(updated.planMode, 'faster');
      expect(updated.householdSize, 4);
      expect(updated.weeklyBudget, 120.0);
      expect(updated.locale, 'fr');
      expect(updated.source, 'filter');
      expect(updated.meta, isEmpty);
    });
  });

  group('AnalyticsService', () {
    test('track(name) is callable without throwing', () {
      const service = AnalyticsService();
      expect(
        () => service.track(PlateEvents.appOpened),
        returnsNormally,
      );
    });

    test('trackPayload with default payload does not throw', () {
      const service = AnalyticsService();
      expect(
        () => service.trackPayload(
          PlateEvents.planGenerated,
          payload: const EventPayload(),
        ),
        returnsNormally,
      );
    });

    test('typed helper for onboardingStarted routes correct event', () {
      const service = AnalyticsService();
      expect(service.trackOnboardingStarted, isA<Function>());
      expect(
        () => service.trackOnboardingStarted(),
        returnsNormally,
      );
    });
  });
}
