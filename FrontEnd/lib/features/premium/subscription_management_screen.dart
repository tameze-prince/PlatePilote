import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'subscription_provider.dart';

class SubscriptionManagementScreen extends ConsumerWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    return PlateScaffold(
      title: 'Subscription',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscription.planName, style: context.text.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subscription.isPremium
                      ? 'Premium features are active.'
                      : 'Upgrade to unlock advanced automation.',
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.credit_card),
              title: const Text('Payment method'),
              subtitle: Text(subscription.paymentMethod),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/payment-method'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Manage Payment',
            icon: Icons.payment,
            onPressed: () => context.push('/payment-method'),
          ),
        ],
      ),
    );
  }
}
