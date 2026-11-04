import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/providers/app_session_provider.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'notifications_provider.dart';

/// Écran des préférences de notifications.
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider);
    final session = ref.watch(appSessionProvider);
    final pushAvailable = Firebase.apps.isNotEmpty;
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return PlateScaffold(
      title: 'Notification Preferences',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SwitchListTile(
            value: pushAvailable && session.hasAcceptedPush,
            onChanged: pushAvailable
                ? ref.read(appSessionProvider.notifier).setPushConsent
                : null,
            title: const Text('Push notifications'),
            subtitle: Text(
              pushAvailable
                  ? 'Receive device notifications. You can withdraw this consent at any time.'
                  : 'Remote notifications are not configured in this build.',
            ),
          ),
          SwitchListTile(
            value: preferences.pantryAlerts,
            onChanged: notifier.setPantryAlerts,
            title: const Text('Pantry alerts'),
            subtitle: const Text('Expiration and use-soon reminders'),
          ),
          SwitchListTile(
            value: preferences.budgetAlerts,
            onChanged: notifier.setBudgetAlerts,
            title: const Text('Budget alerts'),
            subtitle: const Text('Warnings when spending crosses your limit'),
          ),
          SwitchListTile(
            value: preferences.weeklyReminders,
            onChanged: notifier.setWeeklyReminders,
            title: const Text('Weekly reminders'),
            subtitle: const Text('Meal plan and grocery preparation prompts'),
          ),
          SwitchListTile(
            value: preferences.promotionalNotifications,
            onChanged: notifier.setPromotionalNotifications,
            title: const Text('Promotional notifications'),
            subtitle: const Text('Premium feature and offer updates'),
          ),
        ],
      ),
    );
  }
}
