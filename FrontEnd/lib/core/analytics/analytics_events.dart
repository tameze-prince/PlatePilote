class PlateEvents {
  const PlateEvents._();

  static const String appOpened = 'app_opened';
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingSkipped = 'onboarding_skipped';

  static const String onboardingStep1Household = 'onboarding_step1_household';
  static const String onboardingStep2Budget = 'onboarding_step2_budget';
  static const String onboardingStep3Dietary = 'onboarding_step3_dietary';
  static const String onboardingStep4Allergies = 'onboarding_step4_allergies';

  static const String planGenerated = 'plan_generated';
  static const String planRegenerated = 'plan_regenerated';
  static const String planActivated = 'plan_activated';
  static const String filterApplied = 'filter_applied';

  static const String groceryListGenerated = 'grocery_list_generated';
  static const String groceryItemChecked = 'grocery_item_checked';
  static const String groceryListExported = 'grocery_list_exported';
  static const String groceryListShared = 'grocery_list_shared';

  static const String mealSwapped = 'meal_swapped';

  static const String pantryItemAdded = 'pantry_item_added';
  static const String pantryItemRemoved = 'pantry_item_removed';
  static const String pantryItemConsumed = 'pantry_item_consumed';

  static const String signupCompleted = 'signup_completed';
  static const String loginCompleted = 'login_completed';
  static const String emailVerified = 'email_verified';
  static const String logoutCompleted = 'logout_completed';

  static const String upgradeScreenViewed = 'upgrade_screen_viewed';
  static const String checkoutStarted = 'checkout_started';
  static const String checkoutCompleted = 'checkout_completed';
  static const String checkoutCancelled = 'checkout_cancelled';
}
