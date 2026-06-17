// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'PlatePilote';

  @override
  String get splashTagline => 'Dein intelligenter Essens-Begleiter';

  @override
  String get splashGetStarted => 'Loslegen';

  @override
  String get step1Title => 'Lernen wir deinen Haushalt kennen';

  @override
  String get step1Subtitle =>
      'PlatePilote passt Portionen, Zubereitungszeit und Budget an deine Küche an.';

  @override
  String get step2Title => 'Setze dein Budget und deine Grenzen';

  @override
  String get step2Subtitle =>
      'Halte Mahlzeiten realistisch, ohne an Vielfalt zu verlieren.';

  @override
  String get step3Title => 'Wähle deine Ziele';

  @override
  String get step3Subtitle =>
      'Eine optionale Vorratskammer-Einrichtung hilft PlatePilote, das zu nutzen, was du bereits hast.';

  @override
  String get householdSize => 'Für wie viele Personen kochst du normalerweise?';

  @override
  String get cookingProfile => 'Kochprofil';

  @override
  String get weeklyBudget => 'Wöchentliches Lebensmittelbudget';

  @override
  String get cookingTime => 'Kochzeit';

  @override
  String get dietaryPrefs => 'Ernährungspräferenzen';

  @override
  String get goals => 'Was sollte PlatePilote optimieren?';

  @override
  String get continueBtn => 'Weiter';

  @override
  String get backBtn => 'Zurück';

  @override
  String get doneBtn => 'Weiter zur Anmeldung';

  @override
  String stepOf(Object current, Object total) {
    return 'Schritt $current von $total';
  }

  @override
  String get householdSetup => 'Haushalt einrichten';

  @override
  String get budgetConstraints => 'Budget & Einschränkungen';

  @override
  String get goalsPantry => 'Ziele & Vorratskammer';

  @override
  String get beginner => 'Anfänger';

  @override
  String get balanced => 'Ausgewogen';

  @override
  String get batchCook => 'Batch-Kochen';

  @override
  String get chefMode => 'Chef-Modus';

  @override
  String get flexible => 'Flexibel';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get highProtein => 'Hoher Proteingehalt';

  @override
  String get vegetarian => 'Vegetarisch';

  @override
  String get glutenFree => 'Glutenfrei';

  @override
  String get lowCarb => 'Low Carb';

  @override
  String get saveMoney => 'Geld sparen';

  @override
  String get eatHealthier => 'Gesünder essen';

  @override
  String get wasteLess => 'Weniger verschwenden';

  @override
  String get cookFaster => 'Schneller kochen';

  @override
  String get pantryLater =>
      'Die Vorratskammer-Einrichtung kann später über den Vorratskammer-Tab abgeschlossen werden.';

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
    return 'Guten Morgen, $name!';
  }

  @override
  String get homeSubtitle => 'Bereit, auf Kurs zu bleiben und heute zu sparen?';

  @override
  String get budgetStatus => 'Budgetstatus';

  @override
  String percentSpent(Object percent) {
    return '$percent% ausgegeben';
  }

  @override
  String get budgetRemaining => 'Verbleibendes Budget';

  @override
  String get yourPlanToday => 'Dein Plan für heute';

  @override
  String get viewFullPlan => 'Vollständigen Plan anzeigen';

  @override
  String get quickMealMode => 'Schnellgericht-Modus';

  @override
  String pantryWarning(Object items) {
    return '$items sollten diese Woche verwendet werden.';
  }

  @override
  String get welcomeBack => 'Willkommen zurück';

  @override
  String get signInSubtitle =>
      'Melde dich an, um deinen Wochenplan und deine Einkaufsliste synchron zu halten.';

  @override
  String get signIn => 'Anmelden';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get createAccountTitle => 'Erstelle dein PlatePilote-Konto';

  @override
  String get signupSubtitle =>
      'Personalisierte Mahlzeitenplanung beginnt mit ein paar Grundlagen.';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get emailAddress => 'E-Mail-Adresse';

  @override
  String get password => 'Passwort';

  @override
  String get haveAccount => 'Ich habe bereits ein Konto';

  @override
  String get yourWeek => 'Deine Woche';

  @override
  String mealsSelected(Object count) {
    return '$count ausgewogene Mahlzeiten für deinen Haushalt ausgewählt.';
  }

  @override
  String get quickMeal => 'Schnellgericht';

  @override
  String get expressMode => 'Express-Modus';

  @override
  String get groceryList => 'Einkaufsliste';

  @override
  String get readyToBuy => 'Kaufbereit';

  @override
  String get estimatedBudget => 'Geschätztes Budget';

  @override
  String budgetDetail(Object items, Object pantry, Object total) {
    return '$total für $items Einkaufsartikel, einschließlich $pantry Vorratskammer-Zutaten.';
  }

  @override
  String get replace => 'Ersetzen';

  @override
  String get regenerate => 'Neu generieren';

  @override
  String get estimatedTotal => 'Geschätzte Summe';

  @override
  String get withinBudget => 'Innerhalb des Budgets';

  @override
  String itemsToBuy(Object count, Object pantry) {
    return '$count Artikel zu kaufen - $pantry Artikel in der Vorratskammer';
  }

  @override
  String get items => 'Artikel';

  @override
  String get searchIngredients => 'Zutaten suchen...';

  @override
  String get allItems => 'Alle Artikel';

  @override
  String get scanOrAdd => 'Scannen oder zur Vorratskammer hinzufügen';

  @override
  String get useSoon => 'Bald verwenden';

  @override
  String preventWaste(Object amount, Object item, Object recipe) {
    return 'Verwende $item heute Abend in $recipe, um Verschwendung zu vermeiden und ca. $amount zu sparen.';
  }

  @override
  String dinnerIn(Object minutes) {
    return 'Abendessen in $minutes Minuten';
  }

  @override
  String get quickMealDesc =>
      'Basierend auf deiner Vorratskammer, Budget und Präferenz für schnelle Zubereitung.';

  @override
  String get bestMatches => 'Beste Übereinstimmungen';

  @override
  String get swap => 'Tauschen';

  @override
  String get cook => 'Kochen';

  @override
  String get unlockSmarter => 'Schalte intelligentere Mahlzeitenplanung frei';

  @override
  String get premiumSubtitle =>
      'Erweiterte Budgetprognosen, unbegrenzte Vorratskammer-Scans, Familienprofile und tiefere Einkaufsersparnisse.';

  @override
  String perMonth(Object price) {
    return '$price / Monat';
  }

  @override
  String get aiPlanRegen => 'KI-Planregenerierung';

  @override
  String get aiPlanRegenSub =>
      'Tausche Mahlzeiten aus, während du Budget und Ernährung bewahrst.';

  @override
  String get unlimitedScans => 'Unbegrenzte Vorratskammer-Scans';

  @override
  String get unlimitedScansSub =>
      'Quittungs-, Barcode- und kamerabasierte Vorratskammer-Erfassung.';

  @override
  String get savingsIntelligence => 'Spar-Intelligenz';

  @override
  String get savingsIntelligenceSub =>
      'Verfolge Abfallvermeidung und beste Substitutionen.';

  @override
  String get startTrial => 'Premium-Testversion starten';

  @override
  String get profilePrefs => 'Profil & Präferenzen';

  @override
  String get profilePrefsSub => 'Haushalt, Ziele, Küchen, Allergien';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get notificationsSub =>
      'Vorratskammer-Warnungen und Plan-Erinnerungen';

  @override
  String get customRecipes => 'Eigene Rezepte';

  @override
  String get customRecipesSub => 'Speichere deine eigenen Rezepte';

  @override
  String get theme => 'Design';

  @override
  String get settings => 'Settings';

  @override
  String get upgradeToPremium => 'Auf Premium upgraden';

  @override
  String get language => 'Sprache';

  @override
  String get languageSub => 'English / Français / Deutsch';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageDe => 'Deutsch';

  @override
  String get editPreferences => 'Präferenzen bearbeiten';

  @override
  String get budgetManagement => 'Budgetverwaltung';

  @override
  String get addPantryItem => 'Zur Vorratskammer hinzufügen';

  @override
  String get addGroceryItem => 'Artikel hinzufügen';

  @override
  String get addRecipe => 'Rezept hinzufügen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Etwas ist schiefgelaufen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get search => 'Suchen';

  @override
  String get noResults => 'Keine Ergebnisse gefunden';

  @override
  String premiumTrialDays(Object days) {
    return 'Premium-Testversion - $days Tage übrig';
  }

  @override
  String get followsSystem => 'Folgt der Systemdarstellung';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get lightMode => 'Hellmodus';

  @override
  String weeklyCap(Object amount) {
    return 'Wöchentliches Limit $amount';
  }

  @override
  String get activeUsers => 'aktive Nutzer';

  @override
  String get appRating => 'im Play Store';

  @override
  String get avgSavings => 'durchschnittlich gespart';

  @override
  String get testimonial1Text =>
      'Ich spare jeden Woche 2 Stunden beim Einkaufen!';

  @override
  String get testimonial2Text =>
      'Die Mahlzeitenpläne haben meine Ernährung verändert.';

  @override
  String get testimonial3Text =>
      'Endlich eine App, die afrikanische Küche versteht!';

  @override
  String get funnelSkip => 'Überspringen';

  @override
  String get funnelTrialBadge => '7 TAGE KOSTENLOS';

  @override
  String get funnelExplainTitle => 'Weniger entscheiden, mehr sparen';

  @override
  String get funnelExplainSubtitle =>
      'PlatePilote plant deine Mahlzeiten, erstellt deine Einkaufsliste und überwacht dein Budget — automatisch.';

  @override
  String get funnelBenefitAiTitle => 'Unbegrenzte KI-Pläne';

  @override
  String get funnelBenefitAiSub =>
      'Woche regenerieren, wann du willst, Budget und Ernährung bleiben erhalten.';

  @override
  String get funnelBenefitGroceryTitle => 'Automatisch erstellte Einkaufsliste';

  @override
  String get funnelBenefitGrocerySub =>
      'Nach Gang sortiert, Mengen an deinen Haushalt angepasst.';

  @override
  String get funnelBenefitBudgetTitle => 'Budget-Optimierer';

  @override
  String get funnelBenefitBudgetSub =>
      'Intelligente Substitutionen, um unter deinem Wochenlimit zu bleiben.';

  @override
  String get funnelCtaPickPlan => 'Pläne anzeigen';

  @override
  String get funnelPickPlanTitle => 'Wähle deinen Plan';

  @override
  String get funnelMonthlyLabel => 'Monatlich';

  @override
  String get funnelAnnualLabel => 'Jährlich';

  @override
  String get funnelMonthlyTitle => 'Monatlich';

  @override
  String get funnelMonthlyTag => 'OHNE VERPFLICHTUNG';

  @override
  String get funnelMonthlyPrice => '6,99 \$';

  @override
  String get funnelAnnualTitle => 'Jährlich';

  @override
  String get funnelAnnualPrice => '59,99 \$';

  @override
  String get funnelAnnualEquiv => '~4,99 \$/Monat';

  @override
  String get funnelPerMonth => '/ Monat';

  @override
  String get funnelPerYear => '/ Jahr';

  @override
  String get funnelSaveBadge => 'SPAARE 28%';

  @override
  String get featuresTitle => 'Premium features';

  @override
  String get funnelFeaturesTitle => 'Alles in Premium';

  @override
  String get funnelFeatureAi => 'Unbegrenzte KI-Plan-Regenerierung';

  @override
  String get funnelFeatureGrocery =>
      'Intelligente Einkaufsliste mit Gangsortierung';

  @override
  String get funnelFeatureBudget => 'Budgetoptimierung und Spar-Tracking';

  @override
  String get funnelFeatureScans => 'Unbegrenzte Quittungs- und Barcode-Scans';

  @override
  String get funnelFeatureFamily => 'Familienprofile und Präferenzen';

  @override
  String get funnelSocialProof => '12.400 Haushalte vertrauen PlatePilote';

  @override
  String get funnelCtaStartTrial => 'Kostenlos testen';

  @override
  String get funnelTrialCopy => '7 Tage kostenlos, jederzeit kündbar';

  @override
  String get funnelPaymentTitle => 'Abonnement abschließen';

  @override
  String get funnelPaymentMethods => 'Zahlungsmethode';

  @override
  String get funnelApplePay => 'Apple Pay';

  @override
  String get funnelGooglePay => 'Google Pay';

  @override
  String get funnelCard => 'Kreditkarte';

  @override
  String get funnelSubscribe => 'Abonnieren';

  @override
  String get funnelLegalFooter =>
      'Mit dem Abonnement akzeptierst du unsere AGB und Datenschutzerklärung.';

  @override
  String get cmdPaletteSearchHint => 'Überall suchen...';

  @override
  String get cmdPalettePages => 'Seiten';

  @override
  String get cmdPaletteRecipes => 'Rezepte';

  @override
  String get cmdPalettePantry => 'Vorratskammer';

  @override
  String get cmdPaletteEmptyTitle => 'Keine Ergebnisse';

  @override
  String get cmdPaletteEmptyHint =>
      'Versuche ein anderes Stichwort oder drücke Esc zum Schließen.';

  @override
  String cmdPaletteEmptyFor(String query) {
    return 'Keine Ergebnisse für „$query\"';
  }

  @override
  String get cmdPaletteCloseHint => 'Esc zum Schließen';

  @override
  String get emptyPantryTitle => 'Deine Vorratskammer ist leer';

  @override
  String get emptyPantrySubtitle =>
      'Füge deine ersten Zutaten hinzu, um genauere Empfehlungen zu erhalten.';

  @override
  String get emptyPantryCta => 'Zutat hinzufügen';

  @override
  String get emptyGroceryTitle => 'Noch keine Einkäufe';

  @override
  String get emptyGrocerySubtitle =>
      'Erstelle einen Mahlzeitenplan, um deine Einkaufsliste aufzubauen.';

  @override
  String get emptyGroceryCta => 'Plan erstellen';

  @override
  String get emptyFavoritesTitle => 'Noch keine Lieblingsrezepte';

  @override
  String get emptyFavoritesSubtitle =>
      'Speichere deine Lieblingsrezepte, um sie schnell wiederzufinden.';

  @override
  String get emptyFavoritesCta => 'Rezepte durchsuchen';

  @override
  String emptySearchTitle(String query) {
    return 'Keine Ergebnisse für «$query»';
  }

  @override
  String get emptySearchSubtitle => 'Versuche es mit anderen Suchbegriffen.';

  @override
  String get emptyNotificationsTitle => 'Du bist auf dem Laufenden';

  @override
  String get emptyNotificationsSubtitle =>
      'Im Moment keine neuen Benachrichtigungen.';

  @override
  String get emptyQuickMealTitle => 'Kein Rezept zur Hand';

  @override
  String get emptyQuickMealSubtitle =>
      'Füge einige Zutaten zur Vorratskammer hinzu, um Vorschläge zu aktivieren.';

  @override
  String get emptyQuickMealCta => 'Vorratskammer öffnen';

  @override
  String get onboardingSingleTitle => 'Willkommen bei PlatePilot';

  @override
  String get onboardingSingleSubtitle =>
      'Ein paar Angaben und wir entwerfen deine erste Woche.';

  @override
  String get onboardingSingleHousehold => 'Erzähl uns von deinem Haushalt';

  @override
  String onboardingSingleHouseholdPeople(String count) {
    return '$count Personen';
  }

  @override
  String get onboardingSingleCookingProfile => 'Wie kochst du?';

  @override
  String get onboardingSingleBudget => 'Wöchentliches Lebensmittelbudget';

  @override
  String get onboardingSingleCustom => 'Benutzerdefiniert';

  @override
  String get onboardingSingleTime => 'Zeit pro Mahlzeit';

  @override
  String onboardingSingleTimeShort(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get onboardingSingleTimeFlexible => 'Flexibel';

  @override
  String get onboardingSingleDietary => 'Ernährungspräferenzen';

  @override
  String get onboardingSingleGoals => 'Deine Ziele';

  @override
  String get onboardingSingleVegan => 'Vegan';

  @override
  String get onboardingSingleHalal => 'Halal';

  @override
  String get onboardingSingleLactoseFree => 'Laktosefrei';

  @override
  String get onboardingSingleKeto => 'Keto';

  @override
  String get onboardingSinglePescatarian => 'Pescetarisch';

  @override
  String get onboardingSingleGoalSaveMoney => 'Geld sparen';

  @override
  String get onboardingSingleGoalEatHealthier => 'Gesünder essen';

  @override
  String get onboardingSingleGoalWasteLess => 'Weniger verschwenden';

  @override
  String get onboardingSingleGoalCookFaster => 'Schneller kochen';

  @override
  String get onboardingSinglePreviewTitle => 'Deine Woche';

  @override
  String onboardingSinglePreviewRecipes(int count) {
    return '$count Rezepte / Woche';
  }

  @override
  String onboardingSinglePreviewBudget(String amount) {
    return 'Budget $amount';
  }

  @override
  String onboardingSinglePreviewTime(int minutes) {
    return '~$minutes Min. / Mahlzeit';
  }

  @override
  String get onboardingSinglePreviewPantryHint =>
      'Die Vorratskammer kann später eingerichtet werden.';

  @override
  String get onboardingSinglePreviewEmpty =>
      'Wähle mindestens eine Haushaltsgröße, um die Woche anzuzeigen.';

  @override
  String get onboardingSingleCtaSeePlan => 'Meinen Plan ansehen';

  @override
  String get onboardingSingleCtaCreateAccount => 'Konto erstellen';

  @override
  String get onboardingSingleCtaSignInInstead => 'Stattdessen anmelden';

  @override
  String get onboardingSingleCustomizeLater => 'Später anpassen';

  @override
  String get onboardingSingleSkip => 'Überspringen';
}
