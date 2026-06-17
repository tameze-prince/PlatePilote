import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PlatePilot'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your smart meal co-pilot'**
  String get splashTagline;

  /// No description provided for @splashGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get splashGetStarted;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Let us get to know your household'**
  String get step1Title;

  /// No description provided for @step1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'PlatePilot tunes portions, prep time, and budget around your kitchen.'**
  String get step1Subtitle;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Set your budget and boundaries'**
  String get step2Title;

  /// No description provided for @step2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep meals realistic without losing variety.'**
  String get step2Subtitle;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Choose your goals'**
  String get step3Title;

  /// No description provided for @step3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional pantry setup helps PlatePilot use what you already own.'**
  String get step3Subtitle;

  /// No description provided for @householdSize.
  ///
  /// In en, this message translates to:
  /// **'How many people do you usually cook for?'**
  String get householdSize;

  /// No description provided for @cookingProfile.
  ///
  /// In en, this message translates to:
  /// **'Cooking profile'**
  String get cookingProfile;

  /// No description provided for @weeklyBudget.
  ///
  /// In en, this message translates to:
  /// **'Weekly grocery budget'**
  String get weeklyBudget;

  /// No description provided for @cookingTime.
  ///
  /// In en, this message translates to:
  /// **'Cooking time'**
  String get cookingTime;

  /// No description provided for @dietaryPrefs.
  ///
  /// In en, this message translates to:
  /// **'Dietary preferences'**
  String get dietaryPrefs;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'What should PlatePilot optimize for?'**
  String get goals;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @backBtn.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backBtn;

  /// No description provided for @doneBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue to sign in'**
  String get doneBtn;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(Object current, Object total);

  /// No description provided for @householdSetup.
  ///
  /// In en, this message translates to:
  /// **'Household setup'**
  String get householdSetup;

  /// No description provided for @budgetConstraints.
  ///
  /// In en, this message translates to:
  /// **'Budget & constraints'**
  String get budgetConstraints;

  /// No description provided for @goalsPantry.
  ///
  /// In en, this message translates to:
  /// **'Goals & pantry'**
  String get goalsPantry;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @batchCook.
  ///
  /// In en, this message translates to:
  /// **'Batch cook'**
  String get batchCook;

  /// No description provided for @chefMode.
  ///
  /// In en, this message translates to:
  /// **'Chef mode'**
  String get chefMode;

  /// No description provided for @flexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get flexible;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @highProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein'**
  String get highProtein;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @glutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten-free'**
  String get glutenFree;

  /// No description provided for @lowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low carb'**
  String get lowCarb;

  /// No description provided for @saveMoney.
  ///
  /// In en, this message translates to:
  /// **'Save money'**
  String get saveMoney;

  /// No description provided for @eatHealthier.
  ///
  /// In en, this message translates to:
  /// **'Eat healthier'**
  String get eatHealthier;

  /// No description provided for @wasteLess.
  ///
  /// In en, this message translates to:
  /// **'Waste less'**
  String get wasteLess;

  /// No description provided for @cookFaster.
  ///
  /// In en, this message translates to:
  /// **'Cook faster'**
  String get cookFaster;

  /// No description provided for @pantryLater.
  ///
  /// In en, this message translates to:
  /// **'Pantry setup can be finished later from the Pantry tab.'**
  String get pantryLater;

  /// No description provided for @customBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom weekly budget'**
  String get customBudgetTitle;

  /// No description provided for @customBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag the slider or type the exact amount you want to spend on groceries each week.'**
  String get customBudgetSubtitle;

  /// No description provided for @customBudgetApplied.
  ///
  /// In en, this message translates to:
  /// **'\${amount} budget saved'**
  String customBudgetApplied(int amount);

  /// No description provided for @resumeDraft.
  ///
  /// In en, this message translates to:
  /// **'Resume my draft'**
  String get resumeDraft;

  /// No description provided for @resumeDraftTooltip.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get resumeDraftTooltip;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}!'**
  String goodMorning(Object name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to stay on track and save today?'**
  String get homeSubtitle;

  /// No description provided for @budgetStatus.
  ///
  /// In en, this message translates to:
  /// **'Budget Status'**
  String get budgetStatus;

  /// No description provided for @percentSpent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Spent'**
  String percentSpent(Object percent);

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'Budget Remaining'**
  String get budgetRemaining;

  /// No description provided for @yourPlanToday.
  ///
  /// In en, this message translates to:
  /// **'Your Plan for Today'**
  String get yourPlanToday;

  /// No description provided for @viewFullPlan.
  ///
  /// In en, this message translates to:
  /// **'View Full Plan'**
  String get viewFullPlan;

  /// No description provided for @quickMealMode.
  ///
  /// In en, this message translates to:
  /// **'Quick Meal Mode'**
  String get quickMealMode;

  /// No description provided for @pantryWarning.
  ///
  /// In en, this message translates to:
  /// **'{items} should be used this week.'**
  String pantryWarning(Object items);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your weekly plan and grocery list in sync.'**
  String get signInSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your PlatePilot account'**
  String get createAccountTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized meal planning starts with a few basics.'**
  String get signupSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccount;

  /// No description provided for @yourWeek.
  ///
  /// In en, this message translates to:
  /// **'Your Week'**
  String get yourWeek;

  /// No description provided for @mealsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} balanced meals selected for your household.'**
  String mealsSelected(Object count);

  /// No description provided for @quickMeal.
  ///
  /// In en, this message translates to:
  /// **'Quick Meal'**
  String get quickMeal;

  /// No description provided for @expressMode.
  ///
  /// In en, this message translates to:
  /// **'Express mode'**
  String get expressMode;

  /// No description provided for @groceryList.
  ///
  /// In en, this message translates to:
  /// **'Grocery List'**
  String get groceryList;

  /// No description provided for @readyToBuy.
  ///
  /// In en, this message translates to:
  /// **'Ready to buy'**
  String get readyToBuy;

  /// No description provided for @estimatedBudget.
  ///
  /// In en, this message translates to:
  /// **'Estimated Budget'**
  String get estimatedBudget;

  /// No description provided for @budgetDetail.
  ///
  /// In en, this message translates to:
  /// **'{total} for {items} grocery items, including {pantry} pantry ingredients already on hand.'**
  String budgetDetail(Object items, Object pantry, Object total);

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get estimatedTotal;

  /// No description provided for @withinBudget.
  ///
  /// In en, this message translates to:
  /// **'Within Budget'**
  String get withinBudget;

  /// No description provided for @itemsToBuy.
  ///
  /// In en, this message translates to:
  /// **'{count} items to buy - {pantry} items in pantry'**
  String itemsToBuy(Object count, Object pantry);

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @searchIngredients.
  ///
  /// In en, this message translates to:
  /// **'Search ingredients...'**
  String get searchIngredients;

  /// No description provided for @allItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get allItems;

  /// No description provided for @scanOrAdd.
  ///
  /// In en, this message translates to:
  /// **'Scan or Add to Pantry'**
  String get scanOrAdd;

  /// No description provided for @useSoon.
  ///
  /// In en, this message translates to:
  /// **'Use Soon'**
  String get useSoon;

  /// No description provided for @preventWaste.
  ///
  /// In en, this message translates to:
  /// **'Use {item} in tonight\'s {recipe} to prevent waste and save about {amount}.'**
  String preventWaste(Object amount, Object item, Object recipe);

  /// No description provided for @dinnerIn.
  ///
  /// In en, this message translates to:
  /// **'Dinner in {minutes} minutes'**
  String dinnerIn(Object minutes);

  /// No description provided for @quickMealDesc.
  ///
  /// In en, this message translates to:
  /// **'Based on your pantry, budget, and low-prep preference.'**
  String get quickMealDesc;

  /// No description provided for @bestMatches.
  ///
  /// In en, this message translates to:
  /// **'Best Matches'**
  String get bestMatches;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @cook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cook;

  /// No description provided for @unlockSmarter.
  ///
  /// In en, this message translates to:
  /// **'Unlock smarter meal planning'**
  String get unlockSmarter;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced budget forecasting, unlimited pantry scans, family profiles, and deeper grocery savings.'**
  String get premiumSubtitle;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String perMonth(Object price);

  /// No description provided for @aiPlanRegen.
  ///
  /// In en, this message translates to:
  /// **'AI plan regeneration'**
  String get aiPlanRegen;

  /// No description provided for @aiPlanRegenSub.
  ///
  /// In en, this message translates to:
  /// **'Swap meals while preserving budget and nutrition.'**
  String get aiPlanRegenSub;

  /// No description provided for @unlimitedScans.
  ///
  /// In en, this message translates to:
  /// **'Unlimited pantry scans'**
  String get unlimitedScans;

  /// No description provided for @unlimitedScansSub.
  ///
  /// In en, this message translates to:
  /// **'Receipt, barcode, and camera-driven pantry capture.'**
  String get unlimitedScansSub;

  /// No description provided for @savingsIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Savings intelligence'**
  String get savingsIntelligence;

  /// No description provided for @savingsIntelligenceSub.
  ///
  /// In en, this message translates to:
  /// **'Track waste reduction and best-value substitutions.'**
  String get savingsIntelligenceSub;

  /// No description provided for @startTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Premium Trial'**
  String get startTrial;

  /// No description provided for @profilePrefs.
  ///
  /// In en, this message translates to:
  /// **'Profile & Preferences'**
  String get profilePrefs;

  /// No description provided for @profilePrefsSub.
  ///
  /// In en, this message translates to:
  /// **'Household, goals, cuisines, allergies'**
  String get profilePrefsSub;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Pantry alerts and plan reminders'**
  String get notificationsSub;

  /// No description provided for @customRecipes.
  ///
  /// In en, this message translates to:
  /// **'Custom Recipes'**
  String get customRecipes;

  /// No description provided for @customRecipesSub.
  ///
  /// In en, this message translates to:
  /// **'Save your own recipes'**
  String get customRecipesSub;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSub.
  ///
  /// In en, this message translates to:
  /// **'English / Français / Deutsch'**
  String get languageSub;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageFr.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get settingsLanguageFr;

  /// No description provided for @settingsLanguageDe.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get settingsLanguageDe;

  /// No description provided for @editPreferences.
  ///
  /// In en, this message translates to:
  /// **'Edit Preferences'**
  String get editPreferences;

  /// No description provided for @budgetManagement.
  ///
  /// In en, this message translates to:
  /// **'Budget Management'**
  String get budgetManagement;

  /// No description provided for @addPantryItem.
  ///
  /// In en, this message translates to:
  /// **'Add Pantry Item'**
  String get addPantryItem;

  /// No description provided for @addGroceryItem.
  ///
  /// In en, this message translates to:
  /// **'Add Grocery Item'**
  String get addGroceryItem;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipe;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @premiumTrialDays.
  ///
  /// In en, this message translates to:
  /// **'Premium trial - {days} days left'**
  String premiumTrialDays(Object days);

  /// No description provided for @followsSystem.
  ///
  /// In en, this message translates to:
  /// **'Follows system appearance'**
  String get followsSystem;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @weeklyCap.
  ///
  /// In en, this message translates to:
  /// **'{amount} weekly grocery cap'**
  String weeklyCap(Object amount);

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'active users'**
  String get activeUsers;

  /// No description provided for @appRating.
  ///
  /// In en, this message translates to:
  /// **'on the App Store'**
  String get appRating;

  /// No description provided for @avgSavings.
  ///
  /// In en, this message translates to:
  /// **'saved on average'**
  String get avgSavings;

  /// No description provided for @testimonial1Text.
  ///
  /// In en, this message translates to:
  /// **'I save 45€ per month on groceries thanks to smart substitutions!'**
  String get testimonial1Text;

  /// No description provided for @testimonial2Text.
  ///
  /// In en, this message translates to:
  /// **'The AI meal plan made me discover recipes I would never have tried alone.'**
  String get testimonial2Text;

  /// No description provided for @testimonial3Text.
  ///
  /// In en, this message translates to:
  /// **'Finally an app that understands African cuisine!'**
  String get testimonial3Text;

  /// No description provided for @funnelSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get funnelSkip;

  /// No description provided for @funnelTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'FREE FOR 7 DAYS'**
  String get funnelTrialBadge;

  /// No description provided for @funnelExplainTitle.
  ///
  /// In en, this message translates to:
  /// **'Decide less, save more'**
  String get funnelExplainTitle;

  /// No description provided for @funnelExplainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PlatePilot plans your meals, generates your grocery list, and tracks your budget — automatically.'**
  String get funnelExplainSubtitle;

  /// No description provided for @funnelBenefitAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI plans'**
  String get funnelBenefitAiTitle;

  /// No description provided for @funnelBenefitAiSub.
  ///
  /// In en, this message translates to:
  /// **'Regenerate the week whenever you want, with budget and nutrition preserved.'**
  String get funnelBenefitAiSub;

  /// No description provided for @funnelBenefitGroceryTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-generated grocery list'**
  String get funnelBenefitGroceryTitle;

  /// No description provided for @funnelBenefitGrocerySub.
  ///
  /// In en, this message translates to:
  /// **'Grouped by aisle, with quantities adjusted to your household.'**
  String get funnelBenefitGrocerySub;

  /// No description provided for @funnelBenefitBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget optimizer'**
  String get funnelBenefitBudgetTitle;

  /// No description provided for @funnelBenefitBudgetSub.
  ///
  /// In en, this message translates to:
  /// **'Smart substitutions to stay under your weekly cap.'**
  String get funnelBenefitBudgetSub;

  /// No description provided for @funnelCtaPickPlan.
  ///
  /// In en, this message translates to:
  /// **'See the plans'**
  String get funnelCtaPickPlan;

  /// No description provided for @funnelPickPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your plan'**
  String get funnelPickPlanTitle;

  /// No description provided for @funnelMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get funnelMonthlyLabel;

  /// No description provided for @funnelAnnualLabel.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get funnelAnnualLabel;

  /// No description provided for @funnelMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get funnelMonthlyTitle;

  /// No description provided for @funnelMonthlyTag.
  ///
  /// In en, this message translates to:
  /// **'NO COMMITMENT'**
  String get funnelMonthlyTag;

  /// No description provided for @funnelMonthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'\$6.99'**
  String get funnelMonthlyPrice;

  /// No description provided for @funnelAnnualTitle.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get funnelAnnualTitle;

  /// No description provided for @funnelAnnualPrice.
  ///
  /// In en, this message translates to:
  /// **'\$59.99'**
  String get funnelAnnualPrice;

  /// No description provided for @funnelAnnualEquiv.
  ///
  /// In en, this message translates to:
  /// **'~\$4.99/mo'**
  String get funnelAnnualEquiv;

  /// No description provided for @funnelPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get funnelPerMonth;

  /// No description provided for @funnelPerYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get funnelPerYear;

  /// No description provided for @funnelSaveBadge.
  ///
  /// In en, this message translates to:
  /// **'SAVE 28%'**
  String get funnelSaveBadge;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium features'**
  String get featuresTitle;

  /// No description provided for @funnelFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything in Premium'**
  String get funnelFeaturesTitle;

  /// No description provided for @funnelFeatureAi.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI meal regeneration'**
  String get funnelFeatureAi;

  /// No description provided for @funnelFeatureGrocery.
  ///
  /// In en, this message translates to:
  /// **'Smart grocery list with aisle grouping'**
  String get funnelFeatureGrocery;

  /// No description provided for @funnelFeatureBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget optimization and savings tracking'**
  String get funnelFeatureBudget;

  /// No description provided for @funnelFeatureScans.
  ///
  /// In en, this message translates to:
  /// **'Unlimited receipt and barcode scans'**
  String get funnelFeatureScans;

  /// No description provided for @funnelFeatureFamily.
  ///
  /// In en, this message translates to:
  /// **'Family profiles and preferences'**
  String get funnelFeatureFamily;

  /// No description provided for @funnelSocialProof.
  ///
  /// In en, this message translates to:
  /// **'12,400 households trust PlatePilot'**
  String get funnelSocialProof;

  /// No description provided for @funnelCtaStartTrial.
  ///
  /// In en, this message translates to:
  /// **'Start free trial'**
  String get funnelCtaStartTrial;

  /// No description provided for @funnelTrialCopy.
  ///
  /// In en, this message translates to:
  /// **'7 days free, cancel anytime'**
  String get funnelTrialCopy;

  /// No description provided for @funnelPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Finalize subscription'**
  String get funnelPaymentTitle;

  /// No description provided for @funnelPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get funnelPaymentMethods;

  /// No description provided for @funnelApplePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get funnelApplePay;

  /// No description provided for @funnelGooglePay.
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get funnelGooglePay;

  /// No description provided for @funnelCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get funnelCard;

  /// No description provided for @funnelSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get funnelSubscribe;

  /// No description provided for @funnelLegalFooter.
  ///
  /// In en, this message translates to:
  /// **'By subscribing you accept our Terms and Privacy Policy.'**
  String get funnelLegalFooter;

  /// No description provided for @cmdPaletteSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search anything...'**
  String get cmdPaletteSearchHint;

  /// No description provided for @cmdPalettePages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get cmdPalettePages;

  /// No description provided for @cmdPaletteRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get cmdPaletteRecipes;

  /// No description provided for @cmdPalettePantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get cmdPalettePantry;

  /// No description provided for @cmdPaletteEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get cmdPaletteEmptyTitle;

  /// No description provided for @cmdPaletteEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword, or press Esc to close.'**
  String get cmdPaletteEmptyHint;

  /// No description provided for @cmdPaletteEmptyFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String cmdPaletteEmptyFor(String query);

  /// No description provided for @cmdPaletteCloseHint.
  ///
  /// In en, this message translates to:
  /// **'Esc to close'**
  String get cmdPaletteCloseHint;

  /// No description provided for @emptyPantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pantry is empty'**
  String get emptyPantryTitle;

  /// No description provided for @emptyPantrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first ingredients to get more precise recommendations.'**
  String get emptyPantrySubtitle;

  /// No description provided for @emptyPantryCta.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get emptyPantryCta;

  /// No description provided for @emptyGroceryTitle.
  ///
  /// In en, this message translates to:
  /// **'No groceries yet'**
  String get emptyGroceryTitle;

  /// No description provided for @emptyGrocerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a meal plan to build your shopping list.'**
  String get emptyGrocerySubtitle;

  /// No description provided for @emptyGroceryCta.
  ///
  /// In en, this message translates to:
  /// **'Generate plan'**
  String get emptyGroceryCta;

  /// No description provided for @emptyFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite recipes yet'**
  String get emptyFavoritesTitle;

  /// No description provided for @emptyFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite recipes to find them quickly.'**
  String get emptyFavoritesSubtitle;

  /// No description provided for @emptyFavoritesCta.
  ///
  /// In en, this message translates to:
  /// **'Browse recipes'**
  String get emptyFavoritesCta;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String emptySearchTitle(String query);

  /// No description provided for @emptySearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords.'**
  String get emptySearchSubtitle;

  /// No description provided for @emptyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get emptyNotificationsTitle;

  /// No description provided for @emptyNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No new notifications for now.'**
  String get emptyNotificationsSubtitle;

  /// No description provided for @emptyQuickMealTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipe on hand'**
  String get emptyQuickMealTitle;

  /// No description provided for @emptyQuickMealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a few ingredients to your pantry to unlock suggestions.'**
  String get emptyQuickMealSubtitle;

  /// No description provided for @emptyQuickMealCta.
  ///
  /// In en, this message translates to:
  /// **'Open pantry'**
  String get emptyQuickMealCta;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
