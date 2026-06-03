import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';

/// Notifier qui gère la locale (langue) de l'application.
class LocaleNotifier extends Notifier<Locale> {
  /// Clé de persistance pour la locale.
  static const _localeKey = 'locale';

  @override
  Locale build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_localeKey);
    return Locale(code ?? 'en');
  }

  /// Définit la locale et la persiste.
  Future<void> set(Locale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_localeKey, locale.languageCode);
  }
}

/// Provider Riverpod pour la locale courante.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
