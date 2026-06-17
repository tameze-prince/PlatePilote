// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PlatePilot';

  @override
  String get splashTagline => 'Your smart meal co-pilot';

  @override
  String get splashGetStarted => 'Get Started';

  @override
  String get step1Title => 'Let us get to know your household';

  @override
  String get step1Subtitle =>
      'PlatePilot tunes portions, prep time, and budget around your kitchen.';

  @override
  String get step2Title => 'Set your budget and boundaries';

  @override
  String get step2Subtitle => 'Keep meals realistic without losing variety.';

  @override
  String get step3Title => 'Choose your goals';

  @override
  String get step3Subtitle =>
      'Optional pantry setup helps PlatePilot use what you already own.';

  @override
  String get householdSize => 'How many people do you usually cook for?';

  @override
  String get cookingProfile => 'Cooking profile';

  @override
  String get weeklyBudget => 'Weekly grocery budget';

  @override
  String get cookingTime => 'Cooking time';

  @override
  String get dietaryPrefs => 'Dietary preferences';

  @override
  String get goals => 'What should PlatePilot optimize for?';

  @override
  String get continueBtn => 'Continue';

  @override
  String get backBtn => 'Back';

  @override
  String get doneBtn => 'Continue to sign in';

  @override
  String stepOf(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get householdSetup => 'Household setup';

  @override
  String get budgetConstraints => 'Budget & constraints';

  @override
  String get goalsPantry => 'Goals & pantry';

  @override
  String get beginner => 'Beginner';

  @override
  String get balanced => 'Balanced';

  @override
  String get batchCook => 'Batch cook';

  @override
  String get chefMode => 'Chef mode';

  @override
  String get flexible => 'Flexible';

  @override
  String get custom => 'Custom';

  @override
  String get highProtein => 'High protein';

  @override
  String get vegetarian => 'Vegetarian';

  @override
  String get glutenFree => 'Gluten-free';

  @override
  String get lowCarb => 'Low carb';

  @override
  String get saveMoney => 'Save money';

  @override
  String get eatHealthier => 'Eat healthier';

  @override
  String get wasteLess => 'Waste less';

  @override
  String get cookFaster => 'Cook faster';

  @override
  String get pantryLater =>
      'Pantry setup can be finished later from the Pantry tab.';

  @override
  String get customBudgetTitle => 'Custom weekly budget';

  @override
  String get customBudgetSubtitle =>
      'Drag the slider or type the exact amount you want to spend on groceries each week.';

  @override
  String customBudgetApplied(int amount) {
    return '\$$amount budget saved';
  }

  @override
  String get resumeDraft => 'Resume my draft';

  @override
  String get resumeDraftTooltip => 'Continue where you left off';

  @override
  String goodMorning(Object name) {
    return 'Good morning, $name!';
  }

  @override
  String get homeSubtitle => 'Ready to stay on track and save today?';

  @override
  String get budgetStatus => 'Budget Status';

  @override
  String percentSpent(Object percent) {
    return '$percent% Spent';
  }

  @override
  String get budgetRemaining => 'Budget Remaining';

  @override
  String get yourPlanToday => 'Your Plan for Today';

  @override
  String get viewFullPlan => 'View Full Plan';

  @override
  String get quickMealMode => 'Quick Meal Mode';

  @override
  String pantryWarning(Object items) {
    return '$items should be used this week.';
  }

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle =>
      'Sign in to keep your weekly plan and grocery list in sync.';

  @override
  String get signIn => 'Sign In';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountTitle => 'Create your PlatePilot account';

  @override
  String get signupSubtitle =>
      'Personalized meal planning starts with a few basics.';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get haveAccount => 'I already have an account';

  @override
  String get yourWeek => 'Your Week';

  @override
  String mealsSelected(Object count) {
    return '$count balanced meals selected for your household.';
  }

  @override
  String get quickMeal => 'Quick Meal';

  @override
  String get expressMode => 'Express mode';

  @override
  String get groceryList => 'Grocery List';

  @override
  String get readyToBuy => 'Ready to buy';

  @override
  String get estimatedBudget => 'Estimated Budget';

  @override
  String budgetDetail(Object items, Object pantry, Object total) {
    return '$total for $items grocery items, including $pantry pantry ingredients already on hand.';
  }

  @override
  String get replace => 'Replace';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get estimatedTotal => 'Estimated Total';

  @override
  String get withinBudget => 'Within Budget';

  @override
  String itemsToBuy(Object count, Object pantry) {
    return '$count items to buy - $pantry items in pantry';
  }

  @override
  String get items => 'items';

  @override
  String get searchIngredients => 'Search ingredients...';

  @override
  String get allItems => 'All Items';

  @override
  String get scanOrAdd => 'Scan or Add to Pantry';

  @override
  String get useSoon => 'Use Soon';

  @override
  String preventWaste(Object amount, Object item, Object recipe) {
    return 'Use $item in tonight\'s $recipe to prevent waste and save about $amount.';
  }

  @override
  String dinnerIn(Object minutes) {
    return 'Dinner in $minutes minutes';
  }

  @override
  String get quickMealDesc =>
      'Based on your pantry, budget, and low-prep preference.';

  @override
  String get bestMatches => 'Best Matches';

  @override
  String get swap => 'Swap';

  @override
  String get cook => 'Cook';

  @override
  String get unlockSmarter => 'Unlock smarter meal planning';

  @override
  String get premiumSubtitle =>
      'Advanced budget forecasting, unlimited pantry scans, family profiles, and deeper grocery savings.';

  @override
  String perMonth(Object price) {
    return '$price / month';
  }

  @override
  String get aiPlanRegen => 'AI plan regeneration';

  @override
  String get aiPlanRegenSub =>
      'Swap meals while preserving budget and nutrition.';

  @override
  String get unlimitedScans => 'Unlimited pantry scans';

  @override
  String get unlimitedScansSub =>
      'Receipt, barcode, and camera-driven pantry capture.';

  @override
  String get savingsIntelligence => 'Savings intelligence';

  @override
  String get savingsIntelligenceSub =>
      'Track waste reduction and best-value substitutions.';

  @override
  String get startTrial => 'Start Premium Trial';

  @override
  String get profilePrefs => 'Profile & Preferences';

  @override
  String get profilePrefsSub => 'Household, goals, cuisines, allergies';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSub => 'Pantry alerts and plan reminders';

  @override
  String get customRecipes => 'Custom Recipes';

  @override
  String get customRecipesSub => 'Save your own recipes';

  @override
  String get theme => 'Theme';

  @override
  String get settings => 'Settings';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get language => 'Language';

  @override
  String get languageSub => 'English / Français / Deutsch';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageDe => 'Deutsch';

  @override
  String get editPreferences => 'Edit Preferences';

  @override
  String get budgetManagement => 'Budget Management';

  @override
  String get addPantryItem => 'Add Pantry Item';

  @override
  String get addGroceryItem => 'Add Grocery Item';

  @override
  String get addRecipe => 'Add Recipe';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get search => 'Search';

  @override
  String get noResults => 'No results found';

  @override
  String premiumTrialDays(Object days) {
    return 'Premium trial - $days days left';
  }

  @override
  String get followsSystem => 'Follows system appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String weeklyCap(Object amount) {
    return '$amount weekly grocery cap';
  }

  @override
  String get activeUsers => 'active users';

  @override
  String get appRating => 'on the App Store';

  @override
  String get avgSavings => 'saved on average';

  @override
  String get testimonial1Text =>
      'I save 45€ per month on groceries thanks to smart substitutions!';

  @override
  String get testimonial2Text =>
      'The AI meal plan made me discover recipes I would never have tried alone.';

  @override
  String get testimonial3Text =>
      'Finally an app that understands African cuisine!';

  @override
  String get funnelSkip => 'Skip';

  @override
  String get funnelTrialBadge => 'FREE FOR 7 DAYS';

  @override
  String get funnelExplainTitle => 'Decide less, save more';

  @override
  String get funnelExplainSubtitle =>
      'PlatePilot plans your meals, generates your grocery list, and tracks your budget — automatically.';

  @override
  String get funnelBenefitAiTitle => 'Unlimited AI plans';

  @override
  String get funnelBenefitAiSub =>
      'Regenerate the week whenever you want, with budget and nutrition preserved.';

  @override
  String get funnelBenefitGroceryTitle => 'Auto-generated grocery list';

  @override
  String get funnelBenefitGrocerySub =>
      'Grouped by aisle, with quantities adjusted to your household.';

  @override
  String get funnelBenefitBudgetTitle => 'Budget optimizer';

  @override
  String get funnelBenefitBudgetSub =>
      'Smart substitutions to stay under your weekly cap.';

  @override
  String get funnelCtaPickPlan => 'See the plans';

  @override
  String get funnelPickPlanTitle => 'Pick your plan';

  @override
  String get funnelMonthlyLabel => 'Monthly';

  @override
  String get funnelAnnualLabel => 'Annual';

  @override
  String get funnelMonthlyTitle => 'Monthly';

  @override
  String get funnelMonthlyTag => 'NO COMMITMENT';

  @override
  String get funnelMonthlyPrice => '\$6.99';

  @override
  String get funnelAnnualTitle => 'Annual';

  @override
  String get funnelAnnualPrice => '\$59.99';

  @override
  String get funnelAnnualEquiv => '~\$4.99/mo';

  @override
  String get funnelPerMonth => '/ month';

  @override
  String get funnelPerYear => '/ year';

  @override
  String get funnelSaveBadge => 'SAVE 28%';

  @override
  String get featuresTitle => 'Premium features';

  @override
  String get funnelFeaturesTitle => 'Everything in Premium';

  @override
  String get funnelFeatureAi => 'Unlimited AI meal regeneration';

  @override
  String get funnelFeatureGrocery => 'Smart grocery list with aisle grouping';

  @override
  String get funnelFeatureBudget => 'Budget optimization and savings tracking';

  @override
  String get funnelFeatureScans => 'Unlimited receipt and barcode scans';

  @override
  String get funnelFeatureFamily => 'Family profiles and preferences';

  @override
  String get funnelSocialProof => '12,400 households trust PlatePilot';

  @override
  String get funnelCtaStartTrial => 'Start free trial';

  @override
  String get funnelTrialCopy => '7 days free, cancel anytime';

  @override
  String get funnelPaymentTitle => 'Finalize subscription';

  @override
  String get funnelPaymentMethods => 'Payment method';

  @override
  String get funnelApplePay => 'Apple Pay';

  @override
  String get funnelGooglePay => 'Google Pay';

  @override
  String get funnelCard => 'Credit card';

  @override
  String get funnelSubscribe => 'Subscribe';

  @override
  String get funnelLegalFooter =>
      'By subscribing you accept our Terms and Privacy Policy.';

  @override
  String get cmdPaletteSearchHint => 'Search anything...';

  @override
  String get cmdPalettePages => 'Pages';

  @override
  String get cmdPaletteRecipes => 'Recipes';

  @override
  String get cmdPalettePantry => 'Pantry';

  @override
  String get cmdPaletteEmptyTitle => 'No results';

  @override
  String get cmdPaletteEmptyHint =>
      'Try a different keyword, or press Esc to close.';

  @override
  String cmdPaletteEmptyFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get cmdPaletteCloseHint => 'Esc to close';

  @override
  String get emptyPantryTitle => 'Your pantry is empty';

  @override
  String get emptyPantrySubtitle =>
      'Add your first ingredients to get more precise recommendations.';

  @override
  String get emptyPantryCta => 'Add ingredient';

  @override
  String get emptyGroceryTitle => 'No groceries yet';

  @override
  String get emptyGrocerySubtitle =>
      'Generate a meal plan to build your shopping list.';

  @override
  String get emptyGroceryCta => 'Generate plan';

  @override
  String get emptyFavoritesTitle => 'No favorite recipes yet';

  @override
  String get emptyFavoritesSubtitle =>
      'Save your favorite recipes to find them quickly.';

  @override
  String get emptyFavoritesCta => 'Browse recipes';

  @override
  String emptySearchTitle(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get emptySearchSubtitle => 'Try different keywords.';

  @override
  String get emptyNotificationsTitle => 'You\'re all caught up';

  @override
  String get emptyNotificationsSubtitle => 'No new notifications for now.';

  @override
  String get emptyQuickMealTitle => 'No recipe on hand';

  @override
  String get emptyQuickMealSubtitle =>
      'Add a few ingredients to your pantry to unlock suggestions.';

  @override
  String get emptyQuickMealCta => 'Open pantry';

  @override
  String get onboardingSingleTitle => 'Welcome to PlatePilot';

  @override
  String get onboardingSingleSubtitle =>
      'Tell us a few things and we’ll draft your first week.';

  @override
  String get onboardingSingleHousehold => 'Tell us about your household';

  @override
  String onboardingSingleHouseholdPeople(String count) {
    return '$count people';
  }

  @override
  String get onboardingSingleCookingProfile => 'How do you cook?';

  @override
  String get onboardingSingleBudget => 'Weekly grocery budget';

  @override
  String get onboardingSingleCustom => 'Custom';

  @override
  String get onboardingSingleTime => 'Time per meal';

  @override
  String onboardingSingleTimeShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get onboardingSingleTimeFlexible => 'Flexible';

  @override
  String get onboardingSingleDietary => 'Dietary preferences';

  @override
  String get onboardingSingleGoals => 'Your goals';

  @override
  String get onboardingSingleVegan => 'Vegan';

  @override
  String get onboardingSingleHalal => 'Halal';

  @override
  String get onboardingSingleLactoseFree => 'Lactose-free';

  @override
  String get onboardingSingleKeto => 'Keto';

  @override
  String get onboardingSinglePescatarian => 'Pescatarian';

  @override
  String get onboardingSingleGoalSaveMoney => 'Save money';

  @override
  String get onboardingSingleGoalEatHealthier => 'Eat healthier';

  @override
  String get onboardingSingleGoalWasteLess => 'Waste less';

  @override
  String get onboardingSingleGoalCookFaster => 'Cook faster';

  @override
  String get onboardingSinglePreviewTitle => 'Your week';

  @override
  String onboardingSinglePreviewRecipes(int count) {
    return '$count recipes / week';
  }

  @override
  String onboardingSinglePreviewBudget(String amount) {
    return '\$$amount budget';
  }

  @override
  String onboardingSinglePreviewTime(int minutes) {
    return '~$minutes min / meal';
  }

  @override
  String get onboardingSinglePreviewPantryHint =>
      'Pantry setup can be finished later from the Pantry tab.';

  @override
  String get onboardingSinglePreviewEmpty =>
      'Pick at least one household size to preview your week.';

  @override
  String get onboardingSingleCtaSeePlan => 'See your plan';

  @override
  String get onboardingSingleCtaCreateAccount => 'Create my account';

  @override
  String get onboardingSingleCtaSignInInstead => 'Sign in instead';

  @override
  String get onboardingSingleCustomizeLater => 'Customize later';

  @override
  String get onboardingSingleSkip => 'Skip';
}
