import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'locale_provider.dart';

/// Écran de sélection de la langue de l'application.
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final notifier = ref.read(localeProvider.notifier);

    return PlateScaffold(
      title: 'Language',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          ListTile(
            onTap: () => notifier.set(const Locale('en')),
            title: const Text('English'),
            subtitle: const Text('Default'),
            trailing: locale.languageCode == 'en'
                ? const Icon(Icons.check_circle)
                : null,
          ),
          ListTile(
            onTap: () => notifier.set(const Locale('fr')),
            title: const Text('Français'),
            subtitle: const Text('Interface en français'),
            trailing: locale.languageCode == 'fr'
                ? const Icon(Icons.check_circle)
                : null,
          ),
        ],
      ),
    );
  }
}
