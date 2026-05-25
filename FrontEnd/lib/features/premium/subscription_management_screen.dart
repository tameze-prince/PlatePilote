import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_spacing.dart';
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
      child: subscription.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                      if (subscription.status != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Status: ${subscription.status}',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (subscription.isPremium) ...[
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Manage Billing',
                    icon: Icons.payment,
                    onPressed: () async {
                      final url = await ref.read(subscriptionProvider.notifier).createCustomerPortal();
                      if (url != null && context.mounted) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                  ),
                ],
              ],
            ),
    );
  }
}
