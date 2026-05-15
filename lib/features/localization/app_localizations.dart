import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('fr')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _values = {
    'en': {
      'generatePlan': 'Generate Plan',
      'budgetRemaining': 'Budget Remaining',
      'notifications': 'Notifications',
      'language': 'Language',
      'editPreferences': 'Edit Preferences',
      'budgetManagement': 'Budget Management',
      'addPantryItem': 'Add Pantry Item',
      'addGroceryItem': 'Add Grocery Item',
      'addRecipe': 'Add Recipe',
    },
    'fr': {
      'generatePlan': 'Générer mon plan',
      'budgetRemaining': 'Budget restant',
      'notifications': 'Notifications',
      'language': 'Langue',
      'editPreferences': 'Modifier les préférences',
      'budgetManagement': 'Gestion du budget',
      'addPantryItem': 'Ajouter au garde-manger',
      'addGroceryItem': 'Ajouter un article',
      'addRecipe': 'Ajouter une recette',
    },
  };

  String text(String key) {
    return _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
