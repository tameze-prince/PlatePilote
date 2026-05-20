import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'notifications_provider.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return PlateScaffold(
      title: 'Notification Preferences',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
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
