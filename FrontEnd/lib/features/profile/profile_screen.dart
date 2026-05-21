import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/providers/theme_provider.dart';
import 'providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const FloatingHeader(title: 'Profile'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg,
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _ProfileHeaderCard(profile: profile),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context, 'Personal Information'),
                    const SizedBox(height: AppSpacing.sm),
                    _ProfileInfoCard(profile: profile),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context, 'Food & Preferences'),
                    const SizedBox(height: AppSpacing.sm),
                    _NavigationCard(
                      icon: Icons.restaurant_menu,
                      title: 'Food & Recommendation Preferences',
                      subtitle: 'Diet, allergies, cuisines, goals',
                      onTap: () => context.push('/food-preferences'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _NavigationCard(
                      icon: Icons.payments_outlined,
                      title: 'Budget Management',
                      subtitle: '\$400 weekly grocery cap',
                      onTap: () => context.push('/budget'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _NavigationCard(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English / Français',
                      onTap: () => context.push('/language'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _NavigationCard(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Pantry alerts and plan reminders',
                      onTap: () => context.push('/notification-preferences'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context, 'Appearance'),
                    const SizedBox(height: AppSpacing.sm),
                    _ThemeSelector(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context, 'Support'),
                    const SizedBox(height: AppSpacing.sm),
                    _NavigationCard(
                      icon: Icons.help_outline,
                      title: 'Help & FAQ',
                      subtitle: 'Get help and answers',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _NavigationCard(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _NavigationCard(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Legal terms and conditions',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _DangerZone(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: PremiumTheme.textSecondary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends ConsumerWidget {
  const _ProfileHeaderCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      elevated: true,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryAccentGreen.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.primaryAccentGreen,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryAccentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: AppTypography.headlineSmall.copyWith(
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: AppTypography.bodyMedium.copyWith(
                    color: PremiumTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryAccentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: AppColors.primaryAccentGreen.withOpacity(0.3),
              ),
            ),
            child: Text(
              'Free Trial',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primaryAccentGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends ConsumerWidget {
  const _ProfileInfoCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileProvider.notifier);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      child: Column(
        children: [
          _EditableRow(
            label: 'Name',
            value: profile.displayName,
            onTap: () => _showEditDialog(
              context, 'Display Name', profile.displayName,
              notifier.setDisplayName,
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Email',
            value: profile.email,
            onTap: () => _showEditDialog(
              context, 'Email', profile.email,
              notifier.setEmail,
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Height',
            value: profile.height != null ? '${profile.height!.toStringAsFixed(0)} cm' : '—',
            onTap: () => _showNumberDialog(
              context, 'Height (cm)', profile.height,
              (v) => notifier.setHeight(v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Weight',
            value: profile.weight != null ? '${profile.weight!.toStringAsFixed(0)} kg' : '—',
            onTap: () => _showNumberDialog(
              context, 'Weight (kg)', profile.weight,
              (v) => notifier.setWeight(v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Age',
            value: profile.age != null ? '${profile.age}' : '—',
            onTap: () => _showNumberDialog(
              context, 'Age', profile.age?.toDouble(),
              (v) => notifier.setAge(v?.toInt()),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Gender',
            value: profile.gender ?? '—',
            onTap: () => _showGenderPicker(context, profile.gender, notifier.setGender),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String field,
    String current,
    ValueChanged<String> onSave,
  ) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter $field'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNumberDialog(
    BuildContext context,
    String field,
    double? current,
    ValueChanged<double?> onSave,
  ) {
    final controller = TextEditingController(
      text: current?.toStringAsFixed(0) ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter $field'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              onSave(value);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showGenderPicker(
    BuildContext context,
    String? current,
    ValueChanged<String?> onSave,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Gender'),
        children: ['Male', 'Female', 'Non-binary', 'Prefer not to say'].map(
          (g) => RadioListTile<String>(
            title: Text(g),
            value: g,
            groupValue: current,
            onChanged: (v) {
              onSave(v);
              Navigator.pop(ctx);
            },
          ),
        ).toList(),
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: PremiumTheme.textTertiary(context),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: AppTypography.bodyLarge.copyWith(
                color: PremiumTheme.textPrimary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: PremiumTheme.textTertiary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryAccentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.primaryAccentGreen, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: PremiumTheme.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: PremiumTheme.textTertiary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    String label;
    if (themeMode == ThemeMode.system) {
      label = 'Follows system appearance';
    } else if (themeMode == ThemeMode.dark) {
      label = 'Dark mode';
    } else {
      label = 'Light mode';
    }

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      child: Row(
        children: [
          Icon(
            themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            color: AppColors.primaryAccentGreen,
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
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: PremiumTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18)),
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode, size: 18)),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18)),
            ],
            selected: {themeMode},
            onSelectionChanged: (Set<ThemeMode> selection) {
              ref.read(themeModeProvider.notifier).set(selection.first);
            },
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      backgroundColor: AppColors.error.withOpacity(0.06),
      borderColor: AppColors.error.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Account Actions',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('Delete Account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error.withOpacity(0.7),
                side: BorderSide(color: AppColors.error.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is irreversible. All your data, preferences, '
          'and meal plans will be permanently deleted. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}
