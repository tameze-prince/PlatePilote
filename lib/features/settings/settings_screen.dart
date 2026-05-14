import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/widgets/plate_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final isSystem = themeMode == ThemeMode.system;

    String themeLabel;
    if (isSystem) {
      themeLabel = 'Follows system appearance';
    } else if (isDark) {
      themeLabel = 'Dark mode';
    } else {
      themeLabel = 'Light mode';
    }

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
          _SettingsItem(
            icon: Icons.people_outline,
            title: 'Household',
            subtitle: '2 people - balanced portions',
          ),
          _SettingsItem(
            icon: Icons.payments_outlined,
            title: 'Budget',
            subtitle: r'$400 weekly grocery cap',
          ),
          _SettingsItem(
            icon: Icons.no_food_outlined,
            title: 'Dietary Constraints',
            subtitle: 'High protein, low waste',
          ),
          _SettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Pantry alerts and plan reminders',
          ),
          const SizedBox(height: AppSpacing.xs),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: context.text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(themeLabel, style: context.text.bodyMedium),
                    ],
                  ),
                ),
                Switch(
                  value: isDark,
                  activeTrackColor: ColorTokens.primaryGreen,
                  onChanged: (_) {
                    final next = switch (themeMode) {
                      ThemeMode.light => ThemeMode.dark,
                      ThemeMode.dark => ThemeMode.system,
                      ThemeMode.system => ThemeMode.light,
                    };
                    ref.read(themeModeProvider.notifier).set(next);
                  },
                ),
              ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AppCard(
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
      ),
    );
  }
}
