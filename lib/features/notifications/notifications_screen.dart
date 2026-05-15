import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../shared/models/mvp_entities.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationCategory? filter;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final visible = filter == null
        ? notifications
        : notifications
              .where((notification) => notification.category == filter)
              .toList();

    return PlateScaffold(
      title: 'Notifications',
      showBack: true,
      trailing: IconButton(
        onPressed: () => context.push('/notification-preferences'),
        icon: const Icon(Icons.tune),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: filter == null,
                        onSelected: (_) => setState(() => filter = null),
                      ),
                      for (final category in NotificationCategory.values)
                        ChoiceChip(
                          label: Text(_categoryLabel(category)),
                          selected: filter == category,
                          onSelected: (_) => setState(() => filter = category),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(notificationsProvider.notifier).markAllRead(),
                  child: const Text('Mark all read'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System notifications',
                    style: context.text.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Enable PlatePilot to send phone alerts for reminders, pantry warnings, and budget updates.',
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Enable Notifications',
                    icon: Icons.notifications_active_outlined,
                    onPressed: () async {
                      final granted = await NotificationService.instance
                          .requestPermissions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              granted
                                  ? 'Notifications enabled'
                                  : 'Notifications are not available or were denied',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Test Warning',
                          icon: Icons.warning_amber,
                          onPressed: () =>
                              NotificationService.instance.showWarning(
                                title: 'PlatePilot warning',
                                body:
                                    'You have used 80% of your weekly budget.',
                                payload: '/budget',
                              ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: SecondaryButton(
                          label: 'Test Reminder',
                          icon: Icons.alarm,
                          onPressed: () =>
                              NotificationService.instance.scheduleReminder(
                                title: 'PlatePilot reminder',
                                body: 'Don’t forget to buy 5 remaining items.',
                                delay: const Duration(seconds: 8),
                                payload: '/grocery',
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const EmptyState(
                    icon: Icons.notifications_none,
                    title: 'No notifications',
                    message: 'Everything is calm for now.',
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final notification = visible[index];
                        return Dismissible(
                          key: ValueKey(notification.id),
                          onDismissed: (_) => ref
                              .read(notificationsProvider.notifier)
                              .delete(notification.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: AppSpacing.lg,
                            ),
                            color: ColorTokens.error,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              _categoryIcon(notification.category),
                              color: notification.isRead
                                  ? context.text.bodyMedium?.color
                                  : context.colors.primary,
                            ),
                            title: Text(
                              notification.title,
                              style: context.text.bodyLarge?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(notification.message),
                            trailing: notification.isRead
                                ? null
                                : const Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: ColorTokens.primaryGreen,
                                  ),
                            onTap: () => ref
                                .read(notificationsProvider.notifier)
                                .toggleRead(notification.id),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(NotificationCategory category) {
    return switch (category) {
      NotificationCategory.pantry => 'Pantry',
      NotificationCategory.budget => 'Budget',
      NotificationCategory.mealPlan => 'Plan',
      NotificationCategory.grocery => 'Grocery',
      NotificationCategory.premium => 'Premium',
    };
  }

  IconData _categoryIcon(NotificationCategory category) {
    return switch (category) {
      NotificationCategory.pantry => Icons.kitchen_outlined,
      NotificationCategory.budget => Icons.account_balance_wallet_outlined,
      NotificationCategory.mealPlan => Icons.calendar_month_outlined,
      NotificationCategory.grocery => Icons.shopping_cart_outlined,
      NotificationCategory.premium => Icons.workspace_premium_outlined,
    };
  }
}
