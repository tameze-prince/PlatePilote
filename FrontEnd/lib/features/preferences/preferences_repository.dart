import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_provider.dart';

/// Provider pour [PreferencesRepository].
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepository(ref);
});

/// Repository local des préférences utilisateur.
class PreferencesRepository {
  const PreferencesRepository(this._ref);

  /// Référence Riverpod pour lire les providers.
  final Ref _ref;

  /// Lit les préférences éditables actuelles.
  EditablePreferences read() => _ref.read(editablePreferencesProvider);
}
