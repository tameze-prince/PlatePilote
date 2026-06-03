import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/preferences_provider.dart';

/// Provider Riverpod pour [LocalStorageService].
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref);
});

/// Service d'accès au stockage local via [SharedPreferences].
class LocalStorageService {
  const LocalStorageService(this._ref);

  final Ref _ref;

  /// Récupère une chaîne de caractères pour la clé donnée.
  String? getString(String key) {
    return _ref.read(sharedPreferencesProvider).getString(key);
  }

  /// Enregistre une chaîne de caractères pour la clé donnée.
  Future<void> setString(String key, String value) {
    return _ref.read(sharedPreferencesProvider).setString(key, value);
  }

  /// Récupère un booléen pour la clé donnée, avec une valeur de repli.
  bool getBool(String key, {bool fallback = false}) {
    return _ref.read(sharedPreferencesProvider).getBool(key) ?? fallback;
  }

  /// Enregistre un booléen pour la clé donnée.
  Future<void> setBool(String key, bool value) {
    return _ref.read(sharedPreferencesProvider).setBool(key, value);
  }
}
