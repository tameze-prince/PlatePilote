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
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get language => 'Language';

  @override
  String get languageSub => 'English / Français';

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
}
