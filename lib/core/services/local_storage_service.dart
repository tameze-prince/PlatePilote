import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/preferences_provider.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref);
});

class LocalStorageService {
  const LocalStorageService(this._ref);

  final Ref _ref;

  String? getString(String key) {
    return _ref.read(sharedPreferencesProvider).getString(key);
  }

  Future<void> setString(String key, String value) {
    return _ref.read(sharedPreferencesProvider).setString(key, value);
  }

  bool getBool(String key, {bool fallback = false}) {
    return _ref.read(sharedPreferencesProvider).getBool(key) ?? fallback;
  }

  Future<void> setBool(String key, bool value) {
    return _ref.read(sharedPreferencesProvider).setBool(key, value);
  }
}
