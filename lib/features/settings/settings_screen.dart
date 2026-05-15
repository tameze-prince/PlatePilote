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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
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
          if (isTablet)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                SizedBox(
                  width: screenWidth >= 900 ? 320 : 280,
                  child: _SettingsItem(
                    icon: Icons.people_outline,
                    title: 'Profile & Preferences',
                    subtitle: 'Household, goals, cuisines, allergies',
                    onTap: () => context.push('/preferences'),
                  ),
                ),
                SizedBox(
                  width: screenWidth >= 900 ? 320 : 280,
                  child: _SettingsItem(
                    icon: Icons.payments_outlined,
                    title: 'Budget Management',
                    subtitle: r'$400 weekly grocery cap',
                    onTap: () => context.push('/budget'),
                  ),
                ),
                SizedBox(
                  width: screenWidth >= 900 ? 320 : 280,
                  child: _SettingsItem(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English / Français',
                    onTap: () => context.push('/language'),
                  ),
                ),
                SizedBox(
                  width: screenWidth >= 900 ? 320 : 280,
                  child: _SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Pantry alerts and plan reminders',
                    onTap: () => context.push('/notification-preferences'),
                  ),
                ),
                SizedBox(
                  width: screenWidth >= 900 ? 320 : 280,
                  child: _SettingsItem(
                    icon: Icons.menu_book_outlined,
                    title: 'Custom Recipes',
                    subtitle: 'Save your own recipes',
                    onTap: () => context.push('/recipes/add'),
                  ),
                ),
              ],
            )
          else ...[
            _SettingsItem(
              icon: Icons.people_outline,
              title: 'Profile & Preferences',
              subtitle: 'Household, goals, cuisines, allergies',
              onTap: () => context.push('/preferences'),
            ),
            _SettingsItem(
              icon: Icons.payments_outlined,
              title: 'Budget Management',
              subtitle: r'$400 weekly grocery cap',
              onTap: () => context.push('/budget'),
            ),
            _SettingsItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English / Français',
              onTap: () => context.push('/language'),
            ),
            _SettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Pantry alerts and plan reminders',
              onTap: () => context.push('/notification-preferences'),
            ),
            _SettingsItem(
              icon: Icons.menu_book_outlined,
              title: 'Custom Recipes',
              subtitle: 'Save your own recipes',
              onTap: () => context.push('/recipes/add'),
            ),
          ],
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AppCard(
        onTap: onTap,
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
