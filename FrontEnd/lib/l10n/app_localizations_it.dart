// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'PlatePilot';

  @override
  String get splashTagline => 'Il tuo copilota pasti intelligente';

  @override
  String get splashGetStarted => 'Inizia';

  @override
  String get step1Title => 'Conosciamo la tua famiglia';

  @override
  String get step1Subtitle =>
      'PlatePilot adatta porzioni, tempo di preparazione e budget alla tua cucina.';

  @override
  String get step2Title => 'Imposta budget e limiti';

  @override
  String get step2Subtitle => 'Pasti realistici senza rinunciare alla varietà.';

  @override
  String get step3Title => 'Scegli i tuoi obiettivi';

  @override
  String get step3Subtitle =>
      'La configurazione opzionale della dispensa aiuta PlatePilot a usare ciò che hai già.';

  @override
  String get householdSize => 'Per quante persone cucini di solito?';

  @override
  String get cookingProfile => 'Profilo di cucina';

  @override
  String get weeklyBudget => 'Budget settimanale spesa';

  @override
  String get cookingTime => 'Tempo di cottura';

  @override
  String get dietaryPrefs => 'Preferenze alimentari';

  @override
  String get goals => 'Cosa deve ottimizzare PlatePilot?';

  @override
  String get continueBtn => 'Continua';

  @override
  String get backBtn => 'Indietro';

  @override
  String get doneBtn => 'Vai all\'accesso';

  @override
  String stepOf(Object current, Object total) {
    return 'Passo $current di $total';
  }

  @override
  String get householdSetup => 'Configurazione famiglia';

  @override
  String get budgetConstraints => 'Budget e limiti';

  @override
  String get goalsPantry => 'Obiettivi e dispensa';

  @override
  String get beginner => 'Principiante';

  @override
  String get balanced => 'Equilibrato';

  @override
  String get batchCook => 'Cottura in batch';

  @override
  String get chefMode => 'Modalità chef';

  @override
  String get flexible => 'Flessibile';

  @override
  String get custom => 'Personalizzato';

  @override
  String get highProtein => 'Alto contenuto proteico';

  @override
  String get vegetarian => 'Vegetariano';

  @override
  String get glutenFree => 'Senza glutine';

  @override
  String get lowCarb => 'Pochi carboidrati';

  @override
  String get saveMoney => 'Risparmiare';

  @override
  String get eatHealthier => 'Mangiare più sano';

  @override
  String get wasteLess => 'Meno sprechi';

  @override
  String get cookFaster => 'Cucinare più velocemente';

  @override
  String get pantryLater =>
      'La configurazione della dispensa può essere completata dopo dalla scheda Dispensa.';

  @override
  String get customBudgetTitle => 'Budget settimanale personalizzato';

  @override
  String get customBudgetSubtitle =>
      'Trascina il cursore o inserisci l\'importo esatto che vuoi spendere per la spesa settimanale.';

  @override
  String customBudgetApplied(int amount) {
    return 'Budget di $amount \$ salvato';
  }

  @override
  String get resumeDraft => 'Riprendi la mia bozza';

  @override
  String get resumeDraftTooltip => 'Continua da dove avevi lasciato';

  @override
  String goodMorning(Object name) {
    return 'Buongiorno, $name!';
  }

  @override
  String get homeSubtitle => 'Pronto a restare in rotta e risparmiare oggi?';

  @override
  String get budgetStatus => 'Stato del budget';

  @override
  String percentSpent(Object percent) {
    return '$percent% speso';
  }

  @override
  String get budgetRemaining => 'Budget residuo';

  @override
  String get yourPlanToday => 'Il tuo piano di oggi';

  @override
  String get viewFullPlan => 'Vedi piano completo';

  @override
  String get quickMealMode => 'Modalità pasto rapido';

  @override
  String pantryWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articoli dovrebbero essere usati questa settimana.',
      one: '1 articolo dovrebbe essere usato questa settimana.',
      zero: 'Nessun articolo da usare questa settimana',
    );
    return '$_temp0';
  }

  @override
  String get welcomeBack => 'Bentornato';

  @override
  String get signInSubtitle =>
      'Accedi per sincronizzare piano settimanale e lista della spesa.';

  @override
  String get signIn => 'Accedi';

  @override
  String get createAccount => 'Crea account';

  @override
  String get createAccountTitle => 'Crea il tuo account PlatePilot';

  @override
  String get signupSubtitle =>
      'La pianificazione personalizzata dei pasti inizia con qualche informazione.';

  @override
  String get fullName => 'Nome completo';

  @override
  String get emailAddress => 'Indirizzo email';

  @override
  String get password => 'Password';

  @override
  String get haveAccount => 'Ho già un account';

  @override
  String get yourWeek => 'La tua settimana';

  @override
  String mealsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasti equilibrati selezionati per la tua famiglia.',
      one: '1 pasto equilibrato selezionato per la tua famiglia.',
      zero: 'Nessun pasto selezionato',
    );
    return '$_temp0';
  }

  @override
  String get quickMeal => 'Pasto rapido';

  @override
  String get expressMode => 'Modalità express';

  @override
  String get groceryList => 'Lista della spesa';

  @override
  String get readyToBuy => 'Pronto per l\'acquisto';

  @override
  String get estimatedBudget => 'Budget stimato';

  @override
  String budgetDetail(String total, int items, int pantry) {
    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items articoli della spesa',
      one: '1 articolo della spesa',
    );
    return '$total per $_temp0, di cui $pantry ingredienti già in dispensa.';
  }

  @override
  String itemsToBuy(int count, String pantry) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articoli da comprare - $pantry articoli in dispensa',
      one: '1 articolo da comprare - $pantry articoli in dispensa',
      zero: 'Nessun articolo da comprare',
    );
    return '$_temp0';
  }

  @override
  String get replace => 'Sostituisci';

  @override
  String get regenerate => 'Rigenera';

  @override
  String get estimatedTotal => 'Totale stimato';

  @override
  String get withinBudget => 'Nel budget';

  @override
  String get items => 'articoli';

  @override
  String get searchIngredients => 'Cerca ingredienti...';

  @override
  String get allItems => 'Tutti gli articoli';

  @override
  String get scanOrAdd => 'Scansiona o aggiungi alla dispensa';

  @override
  String get useSoon => 'Da usare presto';

  @override
  String preventWaste(Object amount, Object item, Object recipe) {
    return 'Usa $item stasera in $recipe per evitare sprechi e risparmiare circa $amount.';
  }

  @override
  String dinnerIn(Object minutes) {
    return 'Cena tra $minutes minuti';
  }

  @override
  String get quickMealDesc =>
      'Basato su dispensa, budget e preferenza di preparazione veloce.';

  @override
  String get bestMatches => 'Migliori corrispondenze';

  @override
  String get swap => 'Cambia';

  @override
  String get cook => 'Cucina';

  @override
  String get unlockSmarter =>
      'Sblocca una pianificazione pasti più intelligente';

  @override
  String get premiumSubtitle =>
      'Previsioni budget avanzate, scansioni dispensa illimitate, profili famiglia e risparmi spesa più profondi.';

  @override
  String perMonth(Object price) {
    return '$price / mese';
  }

  @override
  String get aiPlanRegen => 'Rigenerazione piano IA';

  @override
  String get aiPlanRegenSub => 'Cambia i pasti mantenendo budget e nutrizione.';

  @override
  String get unlimitedScans => 'Scansioni dispensa illimitate';

  @override
  String get unlimitedScansSub =>
      'Acquisizione da scontrino, codice a barre e fotocamera.';

  @override
  String get savingsIntelligence => 'Intelligenza risparmio';

  @override
  String get savingsIntelligenceSub =>
      'Monitora la riduzione degli sprechi e le sostituzioni migliori.';

  @override
  String get startTrial => 'Prova Premium';

  @override
  String get profilePrefs => 'Profilo e preferenze';

  @override
  String get profilePrefsSub => 'Famiglia, obiettivi, cucine, allergie';

  @override
  String get notifications => 'Notifiche';

  @override
  String get notificationsSub => 'Allerte dispensa e promemoria piano';

  @override
  String get customRecipes => 'Ricette personalizzate';

  @override
  String get customRecipesSub => 'Salva le tue ricette';

  @override
  String get theme => 'Tema';

  @override
  String get settings => 'Impostazioni';

  @override
  String get upgradeToPremium => 'Passa a Premium';

  @override
  String get language => 'Lingua';

  @override
  String get languageSub =>
      'English / Français / Deutsch / Italiano / Português';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageDe => 'Deutsch';

  @override
  String get editPreferences => 'Modifica preferenze';

  @override
  String get budgetManagement => 'Gestione budget';

  @override
  String get addPantryItem => 'Aggiungi alla dispensa';

  @override
  String get addGroceryItem => 'Aggiungi articolo';

  @override
  String get addRecipe => 'Aggiungi ricetta';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get confirm => 'Conferma';

  @override
  String get loading => 'Caricamento...';

  @override
  String get error => 'Qualcosa è andato storto';

  @override
  String get retry => 'Riprova';

  @override
  String get search => 'Cerca';

  @override
  String get noResults => 'Nessun risultato trovato';

  @override
  String premiumTrialDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Prova Premium - $days giorni rimasti',
      one: 'Prova Premium - 1 giorno rimasto',
      zero: 'Prova Premium terminata',
    );
    return '$_temp0';
  }

  @override
  String get followsSystem => 'Segue l\'aspetto di sistema';

  @override
  String get darkMode => 'Modo scuro';

  @override
  String get lightMode => 'Modo chiaro';

  @override
  String weeklyCap(Object amount) {
    return 'Limite spesa settimanale $amount';
  }

  @override
  String get activeUsers => 'utenti attivi';

  @override
  String get appRating => 'sull\'App Store';

  @override
  String get avgSavings => 'risparmiati in media';

  @override
  String get testimonial1Text =>
      'Risparmio 45€ al mese sulla spesa grazie alle sostituzioni intelligenti!';

  @override
  String get testimonial2Text =>
      'Il piano pasti IA mi ha fatto scoprire ricette che non avrei mai provato da solo.';

  @override
  String get testimonial3Text =>
      'Finalmente un\'app che capisce la cucina africana!';

  @override
  String get funnelSkip => 'Salta';

  @override
  String get funnelTrialBadge => '7 GIORNI GRATUITI';

  @override
  String get funnelExplainTitle => 'Decidi meno, risparmia di più';

  @override
  String get funnelExplainSubtitle =>
      'PlatePilot pianifica i pasti, genera la lista della spesa e monitora il budget — automaticamente.';

  @override
  String get funnelBenefitAiTitle => 'Piani IA illimitati';

  @override
  String get funnelBenefitAiSub =>
      'Rigenera la settimana quando vuoi, con budget e nutrizione invariati.';

  @override
  String get funnelBenefitGroceryTitle => 'Lista della spesa auto-generata';

  @override
  String get funnelBenefitGrocerySub =>
      'Ordinata per reparto, quantità adattate alla tua famiglia.';

  @override
  String get funnelBenefitBudgetTitle => 'Ottimizzatore di budget';

  @override
  String get funnelBenefitBudgetSub =>
      'Sostituzioni intelligenti per restare sotto il tetto settimanale.';

  @override
  String get funnelCtaPickPlan => 'Vedi i piani';

  @override
  String get funnelPickPlanTitle => 'Scegli il tuo piano';

  @override
  String get funnelMonthlyLabel => 'Mensile';

  @override
  String get funnelAnnualLabel => 'Annuale';

  @override
  String get funnelMonthlyTitle => 'Mensile';

  @override
  String get funnelMonthlyTag => 'SENZA IMPEGNO';

  @override
  String get funnelMonthlyPrice => '6,99 \$';

  @override
  String get funnelAnnualTitle => 'Annuale';

  @override
  String get funnelAnnualPrice => '59,99 \$';

  @override
  String get funnelAnnualEquiv => '~4,99 \$/mese';

  @override
  String get funnelPerMonth => '/ mese';

  @override
  String get funnelPerYear => '/ anno';

  @override
  String get funnelSaveBadge => 'RISPARMIA 28%';

  @override
  String get featuresTitle => 'Funzioni Premium';

  @override
  String get funnelFeaturesTitle => 'Tutto in Premium';

  @override
  String get funnelFeatureAi => 'Rigenerazione illimitata dei pasti con IA';

  @override
  String get funnelFeatureGrocery =>
      'Lista della spesa intelligente per reparto';

  @override
  String get funnelFeatureBudget =>
      'Ottimizzazione budget e monitoraggio risparmi';

  @override
  String get funnelFeatureScans =>
      'Scansioni illimitate di scontrini e codici a barre';

  @override
  String get funnelFeatureFamily => 'Profili famiglia e preferenze';

  @override
  String get funnelSocialProof => '12.400 famiglie si fidano di PlatePilot';

  @override
  String get funnelCtaStartTrial => 'Inizia prova gratuita';

  @override
  String get funnelTrialCopy =>
      '7 giorni gratuiti, cancellabile in qualsiasi momento';

  @override
  String get funnelPaymentTitle => 'Finalizza abbonamento';

  @override
  String get funnelPaymentMethods => 'Metodo di pagamento';

  @override
  String get funnelApplePay => 'Apple Pay';

  @override
  String get funnelGooglePay => 'Google Pay';

  @override
  String get funnelCard => 'Carta di credito';

  @override
  String get funnelSubscribe => 'Abbonati';

  @override
  String get funnelLegalFooter =>
      'Abbonandoti accetti i nostri Termini e l\'Informativa sulla privacy.';

  @override
  String get cmdPaletteSearchHint => 'Cerca ovunque...';

  @override
  String get cmdPalettePages => 'Pagine';

  @override
  String get cmdPaletteRecipes => 'Ricette';

  @override
  String get cmdPalettePantry => 'Dispensa';

  @override
  String get cmdPaletteEmptyTitle => 'Nessun risultato';

  @override
  String get cmdPaletteEmptyHint =>
      'Prova un\'altra parola chiave o premi Esc per chiudere.';

  @override
  String cmdPaletteEmptyFor(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get cmdPaletteCloseHint => 'Esc per chiudere';

  @override
  String get emptyPantryTitle => 'La tua dispensa è vuota';

  @override
  String get emptyPantrySubtitle =>
      'Aggiungi i primi ingredienti per ricevere raccomandazioni più precise.';

  @override
  String get emptyPantryCta => 'Aggiungi ingrediente';

  @override
  String get emptyGroceryTitle => 'Nessuna spesa ancora';

  @override
  String get emptyGrocerySubtitle =>
      'Genera un piano pasti per creare la lista della spesa.';

  @override
  String get emptyGroceryCta => 'Genera piano';

  @override
  String get emptyFavoritesTitle => 'Nessuna ricetta preferita';

  @override
  String get emptyFavoritesSubtitle =>
      'Salva le tue ricette preferite per ritrovarle rapidamente.';

  @override
  String get emptyFavoritesCta => 'Sfoglia ricette';

  @override
  String emptySearchTitle(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get emptySearchSubtitle => 'Prova con altre parole chiave.';

  @override
  String get emptyNotificationsTitle => 'Sei in pari';

  @override
  String get emptyNotificationsSubtitle => 'Nessuna nuova notifica al momento.';

  @override
  String get emptyQuickMealTitle => 'Nessuna ricetta pronta';

  @override
  String get emptyQuickMealSubtitle =>
      'Aggiungi qualche ingrediente in dispensa per sbloccare i suggerimenti.';

  @override
  String get emptyQuickMealCta => 'Apri dispensa';

  @override
  String get onboardingSingleTitle => 'Benvenuto in PlatePilot';

  @override
  String get onboardingSingleSubtitle =>
      'Dicci qualche cosa e prepareremo la tua prima settimana.';

  @override
  String get onboardingSingleHousehold => 'Raccontaci della tua famiglia';

  @override
  String onboardingSingleHouseholdPeople(String count) {
    return '$count persone';
  }

  @override
  String get onboardingSingleCookingProfile => 'Come cucini?';

  @override
  String get onboardingSingleBudget => 'Budget spesa settimanale';

  @override
  String get onboardingSingleCustom => 'Personalizzato';

  @override
  String get onboardingSingleTime => 'Tempo per pasto';

  @override
  String onboardingSingleTimeShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get onboardingSingleTimeFlexible => 'Flessibile';

  @override
  String get onboardingSingleDietary => 'Preferenze alimentari';

  @override
  String get onboardingSingleGoals => 'I tuoi obiettivi';

  @override
  String get onboardingSingleVegan => 'Vegano';

  @override
  String get onboardingSingleHalal => 'Halal';

  @override
  String get onboardingSingleLactoseFree => 'Senza lattosio';

  @override
  String get onboardingSingleKeto => 'Cheto';

  @override
  String get onboardingSinglePescatarian => 'Pescetariano';

  @override
  String get onboardingSingleGoalSaveMoney => 'Risparmiare';

  @override
  String get onboardingSingleGoalEatHealthier => 'Mangiare più sano';

  @override
  String get onboardingSingleGoalWasteLess => 'Meno sprechi';

  @override
  String get onboardingSingleGoalCookFaster => 'Cucinare più velocemente';

  @override
  String get onboardingSinglePreviewTitle => 'La tua settimana';

  @override
  String onboardingSinglePreviewRecipes(int count) {
    return '$count ricette / settimana';
  }

  @override
  String onboardingSinglePreviewBudget(String amount) {
    return 'Budget $amount';
  }

  @override
  String onboardingSinglePreviewTime(int minutes) {
    return '~$minutes min / pasto';
  }

  @override
  String get onboardingSinglePreviewPantryHint =>
      'La configurazione della dispensa può essere completata dopo dalla scheda Dispensa.';

  @override
  String get onboardingSinglePreviewEmpty =>
      'Scegli almeno una dimensione famiglia per vedere l\'anteprima della settimana.';

  @override
  String get onboardingSingleCtaSeePlan => 'Vedi il mio piano';

  @override
  String get onboardingSingleCtaCreateAccount => 'Crea il mio account';

  @override
  String get onboardingSingleCtaSignInInstead => 'Accedi invece';

  @override
  String get onboardingSingleCustomizeLater => 'Personalizza dopo';

  @override
  String get onboardingSingleSkip => 'Salta';
}
