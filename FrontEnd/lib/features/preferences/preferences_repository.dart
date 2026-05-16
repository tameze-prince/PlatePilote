import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_provider.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepository(ref);
});

class PreferencesRepository {
  const PreferencesRepository(this._ref);

  final Ref _ref;

  EditablePreferences read() => _ref.read(editablePreferencesProvider);
}
