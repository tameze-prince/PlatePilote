import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/app_session_provider.dart';
import '../../core/widgets/modern_components.dart';
import '../../core/widgets/modern_animations.dart';
import '../../core/widgets/floating_components.dart';
import '../../core/premium_components.dart';
import '../legal/data_rights_repository.dart';
import '../../l10n/app_localizations.dart';

/// Écran des paramètres de l'application.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final isSystem = themeMode == ThemeMode.system;
    final l10n = AppLocalizations.of(context);

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
                l10n.settings,
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Notifications',
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
                            tooltip: 'Edit',
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

                  _buildSectionTitle(context, isDark, l10n.profilePrefs),
                  const SizedBox(height: AppSpacing.sm),

                  AnimatedListItem(
                    delay: 1,
                    child: InfoCard(
                      icon: Icons.people_outline,
                      title: l10n.profilePrefs,
                      description: l10n.profilePrefsSub,
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/preferences'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 2,
                    child: InfoCard(
                      icon: Icons.payments_outlined,
                      title: l10n.budgetManagement,
                      description:
                          l10n.weeklyCap('\$400 ${l10n.weeklyCap('').split(' ').skip(1).join(' ')}'),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/budget'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 3,
                    child: InfoCard(
                      icon: Icons.language,
                      title: l10n.language,
                      description: l10n.languageSub,
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/language'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 4,
                    child: InfoCard(
                      icon: Icons.notifications_outlined,
                      title: l10n.notifications,
                      description: l10n.notificationsSub,
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/notification-preferences'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 5,
                    child: InfoCard(
                      icon: Icons.menu_book_outlined,
                      title: l10n.customRecipes,
                      description: l10n.customRecipesSub,
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push('/recipes/add'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _buildSectionTitle(context, isDark, l10n.theme),
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
                                  l10n.theme,
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
                                  l10n.upgradeToPremium,
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
                      onTap: () => _openUrl(
                        context,
                        'https://platepilote.com/privacy.html',
                      ),
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
                      onTap: () => _openUrl(
                        context,
                        'https://platepilote.com/cgv.html',
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 11,
                    child: InfoCard(
                      icon: Icons.psychology_alt_outlined,
                      title: 'Algorithmic Recommendations',
                      description:
                          'Limited Risk EU AI Act transparency notice',
                      trailing: const Icon(Icons.info_outline, size: 20),
                      onTap: () => _showAlgorithmicNotice(context),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 12,
                    child: InfoCard(
                      icon: Icons.folder_copy_outlined,
                      title: 'My Data',
                      description: 'Export, restrict, or delete your account',
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => _showDataRightsSheet(context, ref),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  AnimatedListItem(
                    delay: 13,
                    child: InfoCard(
                      icon: Icons.analytics_outlined,
                      title: 'Analytics Consent',
                      description:
                          ref.watch(appSessionProvider).hasAcceptedBetaAnalytics
                              ? 'Beta analytics enabled'
                              : 'Beta analytics disabled',
                      trailing: const Icon(Icons.tune, size: 20),
                      onTap: () => _showAnalyticsConsentDialog(context, ref),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AnimatedListItem(
                    delay: 14,
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

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  void _showAlgorithmicNotice(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Algorithmic Recommendations'),
        content: const Text(
          'PlatePilot uses deterministic recommendation scoring for meal suggestions. It does not currently use a generative LLM for recipes. Suggestions are limited-risk, explainable, and always remain under your final choice.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsConsentDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics Consent'),
        content: const Text(
          'Beta analytics help us find crashes and broken journeys. Revoking consent disables analytics locally and you will be asked to accept again before continuing beta use.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final router = GoRouter.of(context);
              final navigator = Navigator.of(context);
              try {
                await ref.read(dataRightsRepositoryProvider).optOutAnalytics();
              } catch (_) {
                // Local revocation still matters even if backend is offline.
              }
              await ref
                  .read(appSessionProvider.notifier)
                  .revokeAnalyticsConsent();
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Analytics consent revoked')),
              );
              router.go('/consent');
            },
            child: const Text('Revoke analytics'),
          ),
        ],
      ),
    );
  }

  void _showDataRightsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'My Data',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => _exportData(context, ref),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export my data'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _restrictProcessing(context, ref),
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Restrict processing'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () => _confirmDeleteAccount(context, ref),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete account'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final data = await ref.read(dataRightsRepositoryProvider).exportData();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Data export'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(data),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Data export failed: $error')),
      );
    } finally {
      if (navigator.canPop()) navigator.pop();
    }
  }

  Future<void> _restrictProcessing(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(dataRightsRepositoryProvider).restrictProcessing();
      messenger.showSnackBar(
        const SnackBar(content: Text('Processing restriction requested')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Restriction request failed: $error')),
      );
    }
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This starts a 30-day soft-delete period before permanent purge. Type DELETE on the next confirmation to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteAccountText(context, ref);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccountText(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Type DELETE'),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final goRouter = GoRouter.of(context);
              if (controller.text.trim() != 'DELETE') {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Confirmation did not match')),
                );
                return;
              }
              try {
                await ref.read(dataRightsRepositoryProvider).deleteAccount();
                await ref.read(appSessionProvider.notifier).signOut();
                navigator.pop();
                goRouter.go('/login');
              } catch (error) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Delete request failed: $error')),
                );
              }
            },
            child: const Text('Delete account'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}
