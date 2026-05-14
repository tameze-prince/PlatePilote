import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/widgets/plate_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _SettingsItem(
        icon: Icons.people_outline,
        title: 'Household',
        subtitle: '2 people - balanced portions',
      ),
      const _SettingsItem(
        icon: Icons.payments_outlined,
        title: 'Budget',
        subtitle: r'$400 weekly grocery cap',
      ),
      const _SettingsItem(
        icon: Icons.no_food_outlined,
        title: 'Dietary Constraints',
        subtitle: 'High protein, low waste',
      ),
      const _SettingsItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Pantry alerts and plan reminders',
      ),
      const _SettingsItem(
        icon: Icons.dark_mode_outlined,
        title: 'Theme',
        subtitle: 'Follows system appearance',
      ),
    ];

    return PlateScaffold(
      title: 'PlatePilot',
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: ColorTokens.primaryGreen.withValues(
                    alpha: 0.16,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: ColorTokens.primaryGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sarah Parker', style: context.text.headlineSmall),
                      Text(
                        'Premium trial - 6 days left',
                        style: context.text.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: item,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Upgrade to Premium',
            icon: Icons.workspace_premium_outlined,
            onPressed: () => context.push('/premium'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(subtitle, style: context.text.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
