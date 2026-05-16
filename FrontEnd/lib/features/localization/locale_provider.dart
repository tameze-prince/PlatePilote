import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';

class LocaleNotifier extends Notifier<Locale> {
  static const _localeKey = 'locale';

  @override
  Locale build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_localeKey);
    return Locale(code ?? 'en');
  }

  Future<void> set(Locale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_localeKey, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
