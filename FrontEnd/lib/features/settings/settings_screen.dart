import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/widgets/modern_components.dart';
import '../../core/widgets/modern_animations.dart';
import '../../core/widgets/floating_components.dart';
import '../../core/premium_components.dart';

/// Écran des paramètres de l'application.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final isSystem = themeMode == ThemeMode.system;

    String themeLabel;
    if (isSystem) {
      themeLabel = 'Follows system appearance';
    } else if (themeMode == ThemeMode.dark) {
      themeLabel = 'Dark mode';
    } else {
      themeLabel = 'Light mode';
    }

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: CustomScrollView(
          slivers: [
          SliverToBoxAdapter(
            child: FloatingAppBar(
              title: Text(
                'Settings',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant
                      : AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Profile Card
                  AnimatedListItem(
                    child: ModernCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: isDark
                                ? AppColors.primaryContainer
                                : AppColors.primaryContainer,
                            child: Icon(
                              Icons.person,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sarah Parker',
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: isDark
                                        ? AppColors.darkOnSurface
                                        : AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Premium trial - 6 days left',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isDark
                                        ? AppColors.darkOnSurfaceVariant
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => context.push('/preferences'),
                            color: isDark
                                ? AppColors.darkOnSurfaceVariant
                                : AppColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _buildSectionTitle(context, isDark, 'Account'),
                  const SizedBox(height: AppSpacing.sm),

                  AnimatedListItem(
                    delay: 1,
                    child: InfoCard(
                      icon: Icons.people_outline,
                      title: 'Profile & Preferences',
                      description: 'Household, goals, cuisines, allergies',
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/preferences'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 2,
                    child: InfoCard(
                      icon: Icons.payments_outlined,
                      title: 'Budget Management',
                      description: '\$400 weekly grocery cap',
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/budget'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 3,
                    child: InfoCard(
                      icon: Icons.language,
                      title: 'Language',
                      description: 'English / Français',
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/language'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 4,
                    child: InfoCard(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      description: 'Pantry alerts and plan reminders',
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/notification-preferences'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 5,
                    child: InfoCard(
                      icon: Icons.menu_book_outlined,
                      title: 'Custom Recipes',
                      description: 'Save your own recipes',
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/recipes/add'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _buildSectionTitle(context, isDark, 'Appearance'),
                  const SizedBox(height: AppSpacing.sm),

                  AnimatedListItem(
                    delay: 6,
                    child: ModernCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(
                            themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Theme',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: isDark
                                        ? AppColors.darkOnSurface
                                        : AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  themeLabel,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isDark
                                        ? AppColors.darkOnSurfaceVariant
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode, size: 18),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.system,
                                icon: Icon(Icons.auto_mode, size: 18),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode, size: 18),
                              ),
                            ],
                            selected: {themeMode},
                            onSelectionChanged: (Set<ThemeMode> selection) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .set(selection.first);
                            },
                            showSelectedIcon: false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _buildSectionTitle(context, isDark, 'Subscription'),
                  const SizedBox(height: AppSpacing.sm),

                  AnimatedListItem(
                    delay: 7,
                    child: ModernCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      color: isDark
                          ? AppColors.primaryContainer
                          : AppColors.primaryContainer,
                      borderColor: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.primaryLight.withValues(alpha: 0.2)
                                      : AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.workspace_premium,
                                  color: isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Premium Plan',
                                      style: AppTypography.titleMedium.copyWith(
                                        color: isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Unlock advanced features',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.primaryLight
                                                .withValues(alpha: 0.7)
                                            : AppColors.primary.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AnimatedButton(
                            onPressed: () => context.push('/premium'),
                            backgroundColor: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_forward, size: 18),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Upgrade to Premium',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: isDark
                                        ? AppColors.darkBackground
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _buildSectionTitle(context, isDark, 'Support'),
                  const SizedBox(height: AppSpacing.sm),

                  AnimatedListItem(
                    delay: 8,
                    child: InfoCard(
                      icon: Icons.help_outline,
                      title: 'Help & FAQ',
                      description: 'Get help and answers',
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 9,
                    child: InfoCard(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      description: 'How we handle your data',
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 10,
                    child: InfoCard(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      description: 'Legal terms and conditions',
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AnimatedListItem(
                    delay: 11,
                    child: TextButton.icon(
                      onPressed: () {
                        // Logout logic
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
      extendBody: true,
    );
  }

  /// Construit un titre de section.
  Widget _buildSectionTitle(
    BuildContext context,
    bool isDark,
    String title,
  ) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: isDark
            ? AppColors.darkOnSurfaceVariant
            : AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
