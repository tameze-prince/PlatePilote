// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'PlatePilot';

  @override
  String get splashTagline => 'Votre copilote repas intelligent';

  @override
  String get splashGetStarted => 'Commencer';

  @override
  String get step1Title => 'Faisons connaissance avec votre foyer';

  @override
  String get step1Subtitle =>
      'PlatePilot adapte les portions, le temps de préparation et le budget à votre cuisine.';

  @override
  String get step2Title => 'Définissez votre budget et vos limites';

  @override
  String get step2Subtitle =>
      'Gardez des repas réalistes sans perdre en variété.';

  @override
  String get step3Title => 'Choisissez vos objectifs';

  @override
  String get step3Subtitle =>
      'La configuration facultative du garde-manger aide PlatePilot à utiliser ce que vous possédez déjà.';

  @override
  String get householdSize =>
      'Pour combien de personnes cuisinez-vous habituellement ?';

  @override
  String get cookingProfile => 'Profil culinaire';

  @override
  String get weeklyBudget => 'Budget hebdomadaire';

  @override
  String get cookingTime => 'Temps de cuisson';

  @override
  String get dietaryPrefs => 'Préférences alimentaires';

  @override
  String get goals => 'Que devrait optimiser PlatePilot ?';

  @override
  String get continueBtn => 'Continuer';

  @override
  String get backBtn => 'Retour';

  @override
  String get doneBtn => 'Continuer vers la connexion';

  @override
  String stepOf(Object current, Object total) {
    return 'Étape $current sur $total';
  }

  @override
  String get householdSetup => 'Configuration du foyer';

  @override
  String get budgetConstraints => 'Budget et contraintes';

  @override
  String get goalsPantry => 'Objectifs et garde-manger';

  @override
  String get beginner => 'Débutant';

  @override
  String get balanced => 'Équilibré';

  @override
  String get batchCook => 'Batch cooking';

  @override
  String get chefMode => 'Mode chef';

  @override
  String get flexible => 'Flexible';

  @override
  String get custom => 'Personnalisé';

  @override
  String get highProtein => 'Riche en protéines';

  @override
  String get vegetarian => 'Végétarien';

  @override
  String get glutenFree => 'Sans gluten';

  @override
  String get lowCarb => 'Faible en glucides';

  @override
  String get saveMoney => 'Économiser';

  @override
  String get eatHealthier => 'Manger plus sain';

  @override
  String get wasteLess => 'Moins gaspiller';

  @override
  String get cookFaster => 'Cuisiner plus vite';

  @override
  String get pantryLater =>
      'La configuration du garde-manger peut être terminée plus tard depuis l\'onglet Garde-manger.';

  @override
  String goodMorning(Object name) {
    return 'Bonjour, $name !';
  }

  @override
  String get homeSubtitle =>
      'Prêt à rester sur la bonne voie et à économiser aujourd\'hui ?';

  @override
  String get budgetStatus => 'État du budget';

  @override
  String percentSpent(Object percent) {
    return '$percent% dépensé';
  }

  @override
  String get budgetRemaining => 'Budget restant';

  @override
  String get yourPlanToday => 'Votre plan du jour';

  @override
  String get viewFullPlan => 'Voir le plan complet';

  @override
  String get quickMealMode => 'Mode repas rapide';

  @override
  String pantryWarning(Object items) {
    return '$items devrait être utilisé cette semaine.';
  }

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInSubtitle =>
      'Connectez-vous pour synchroniser votre plan hebdomadaire et votre liste de courses.';

  @override
  String get signIn => 'Se connecter';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createAccountTitle => 'Créez votre compte PlatePilot';

  @override
  String get signupSubtitle =>
      'La planification personnalisée des repas commence par quelques bases.';

  @override
  String get fullName => 'Nom complet';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get haveAccount => 'J\'ai déjà un compte';

  @override
  String get yourWeek => 'Votre semaine';

  @override
  String mealsSelected(Object count) {
    return '$count repas équilibrés sélectionnés pour votre foyer.';
  }

  @override
  String get quickMeal => 'Repas rapide';

  @override
  String get expressMode => 'Mode express';

  @override
  String get groceryList => 'Liste de courses';

  @override
  String get readyToBuy => 'Prêt à acheter';

  @override
  String get estimatedBudget => 'Budget estimé';

  @override
  String budgetDetail(Object items, Object pantry, Object total) {
    return '$total pour $items articles, dont $pantry ingrédients déjà en garde-manger.';
  }

  @override
  String get replace => 'Remplacer';

  @override
  String get regenerate => 'Régénérer';

  @override
  String get estimatedTotal => 'Total estimé';

  @override
  String get withinBudget => 'Dans le budget';

  @override
  String itemsToBuy(Object count, Object pantry) {
    return '$count articles à acheter - $pantry articles en garde-manger';
  }

  @override
  String get items => 'articles';

  @override
  String get searchIngredients => 'Rechercher des ingrédients...';

  @override
  String get allItems => 'Tous les articles';

  @override
  String get scanOrAdd => 'Scanner ou ajouter au garde-manger';

  @override
  String get useSoon => 'À utiliser bientôt';

  @override
  String preventWaste(Object amount, Object item, Object recipe) {
    return 'Utilisez $item dans $recipe ce soir pour éviter le gaspillage et économiser environ $amount.';
  }

  @override
  String dinnerIn(Object minutes) {
    return 'Dîner en $minutes minutes';
  }

  @override
  String get quickMealDesc =>
      'Basé sur votre garde-manger, budget et préférence de préparation rapide.';

  @override
  String get bestMatches => 'Meilleures correspondances';

  @override
  String get swap => 'Échanger';

  @override
  String get cook => 'Cuisiner';

  @override
  String get unlockSmarter =>
      'Débloquez une planification repas plus intelligente';

  @override
  String get premiumSubtitle =>
      'Prévisions budgétaires avancées, scans de garde-manger illimités, profils familiaux et économies d\'épicerie plus profondes.';

  @override
  String perMonth(Object price) {
    return '$price / mois';
  }

  @override
  String get aiPlanRegen => 'Régénération de plan par IA';

  @override
  String get aiPlanRegenSub =>
      'Échangez des repas tout en préservant le budget et la nutrition.';

  @override
  String get unlimitedScans => 'Scans de garde-manger illimités';

  @override
  String get unlimitedScansSub => 'Capture par reçu, code-barres et caméra.';

  @override
  String get savingsIntelligence => 'Intelligence d\'économie';

  @override
  String get savingsIntelligenceSub =>
      'Suivez la réduction du gaspillage et les substitutions au meilleur rapport qualité-prix.';

  @override
  String get startTrial => 'Essai Premium';

  @override
  String get profilePrefs => 'Profil et préférences';

  @override
  String get profilePrefsSub => 'Foyer, objectifs, cuisines, allergies';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSub => 'Alertes garde-manger et rappels de plan';

  @override
  String get customRecipes => 'Recettes personnalisées';

  @override
  String get customRecipesSub => 'Sauvegardez vos propres recettes';

  @override
  String get theme => 'Thème';

  @override
  String get settings => 'Paramètres';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get language => 'Langue';

  @override
  String get languageSub => 'English / Français / Deutsch';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageDe => 'Deutsch';

  @override
  String get editPreferences => 'Modifier les préférences';

  @override
  String get budgetManagement => 'Gestion du budget';

  @override
  String get addPantryItem => 'Ajouter au garde-manger';

  @override
  String get addGroceryItem => 'Ajouter un article';

  @override
  String get addRecipe => 'Ajouter une recette';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Une erreur est survenue';

  @override
  String get retry => 'Réessayer';

  @override
  String get search => 'Rechercher';

  @override
  String get noResults => 'Aucun résultat trouvé';

  @override
  String premiumTrialDays(Object days) {
    return 'Essai Premium - $days jours restants';
  }

  @override
  String get followsSystem => 'Suit l\'apparence du système';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String weeklyCap(Object amount) {
    return 'Plafond hebdomadaire de $amount';
  }

  @override
  String get activeUsers => 'utilisateurs actifs';

  @override
  String get appRating => 'sur l\'App Store';

  @override
  String get avgSavings => 'économisés en moyenne';

  @override
  String get testimonial1Text =>
      'J\'économise 45€ par mois sur mes courses grâce aux substitutions intelligentes.';

  @override
  String get testimonial2Text =>
      'Le plan de repas AI m\'a fait découvrir des recettes que je n\'aurais jamais essayé seul.';

  @override
  String get testimonial3Text =>
      'Enfin une app qui comprend la cuisine africaine!';
}
