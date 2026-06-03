import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';


import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/providers/theme_provider.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/providers/auth_state.dart';
import 'providers/profile_provider.dart';

/// Écran du profil utilisateur avec paramètres et navigation.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// Indique si la sauvegarde est en cours.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadFromApi();
    });
  }

  /// Ouvre le sélecteur d'image pour l'avatar.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final base64 = base64Encode(bytes);
    await ref.read(profileProvider.notifier).setAvatarBytes(base64);
  }

  /// Sauvegarde les modifications du profil via l'API.
  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await ref.read(profileProvider.notifier).saveToApi();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final notifier = ref.read(profileProvider.notifier);
    final hasChanges = notifier.hasUnsavedChanges;

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FloatingHeader(
                title: 'Profile',
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccentGreen,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: PremiumTheme.glow(context),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: PremiumTheme.isDark(context)
                          ? AppColors.darkBackground
                          : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, 80,
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _ProfileHeaderCard(
                      profile: profile,
                      authState: authState,
                      onAvatarTap: _pickImage,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProfileCompleteness(profile: profile),
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
                    _SaveProfileButton(
                      hasChanges: hasChanges,
                      saving: _saving,
                      onSave: _saveProfile,
                    ),
                    const SizedBox(height: AppSpacing.md),
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

  /// Construit un titre de section.
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

/// Carte indiquant le taux de complétion du profil.
class _ProfileCompleteness extends ConsumerWidget {
  const _ProfileCompleteness({required this.profile});

  /// Profil utilisateur.
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completeness = ref.watch(profileCompletenessProvider);
    if (completeness >= 1.0) return const SizedBox.shrink();

    final missingCount = 8 - profile.completeness;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      backgroundColor: AppColors.warning.withOpacity(0.08),
      borderColor: AppColors.warning.withOpacity(0.2),
      child: InkWell(
        onTap: () => _showMissingInfo(context, profile),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your profile',
                    style: AppTypography.bodyMedium.copyWith(
                      color: PremiumTheme.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$missingCount field${missingCount > 1 ? 's' : ''} missing for better recommendations',
                    style: AppTypography.bodySmall.copyWith(
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: PremiumTheme.textTertiary(context)),
          ],
        ),
      ),
    );
  }

  /// Affiche une boîte de dialogue avec la liste des champs manquants.
  void _showMissingInfo(BuildContext context, UserProfile profile) {
    final missing = <String>[];
    if (profile.gender == null) missing.add('Gender');
    if (profile.heightCm == null) missing.add('Height');
    if (profile.weightKg == null) missing.add('Weight');
    if (profile.dateOfBirth == null) missing.add('Date of Birth');
    if (profile.activityLevel == null) missing.add('Activity Level');
    if (profile.cookingSkill == null) missing.add('Cooking Skill');
    if (profile.householdSize == null) missing.add('Household Size');
    if (profile.healthGoals == null || profile.healthGoals!.isEmpty) {
      missing.add('Health Goals');
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Optimize Recommendations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fill in these fields to help PlatePilot\'s recommendation engine '
              'provide the best meal suggestions for you:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.md),
            ...missing.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record, size: 8, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Text(f, style: const TextStyle(fontSize: 14)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Fill Now'),
          ),
        ],
      ),
    );
  }
}

/// Carte d'en-tête du profil avec avatar et informations.
class _ProfileHeaderCard extends ConsumerWidget {
  const _ProfileHeaderCard({
    required this.profile,
    required this.authState,
    required this.onAvatarTap,
  });

  /// Profil utilisateur.
  final UserProfile profile;
  /// État d'authentification.
  final AuthState authState;
  /// Callback au tap sur l'avatar.
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      elevated: true,
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryAccentGreen.withOpacity(0.2),
                  backgroundImage: profile.avatarBytes != null
                      ? MemoryImage(
                          base64Decode(profile.avatarBytes!),
                        )
                      : null,
                  child: profile.avatarBytes == null
                      ? Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.primaryAccentGreen,
                        )
                      : null,
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
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.name ?? profile.displayName,
                  style: AppTypography.headlineSmall.copyWith(
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  authState.email ?? profile.email,
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

/// Carte des informations personnelles éditables.
class _ProfileInfoCard extends ConsumerWidget {
  const _ProfileInfoCard({required this.profile});

  /// Profil utilisateur.
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
            value: profile.displayName.isNotEmpty ? profile.displayName : '—',
            icon: Icons.person_outline,
            onTap: () => _showEditDialog(
              context, 'Display Name', profile.displayName,
              (v) => notifier.updateProfile(displayName: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Email',
            value: profile.email.isNotEmpty ? profile.email : '—',
            icon: Icons.email_outlined,
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Date of Birth',
            value: profile.dateOfBirth ?? '—',
            icon: Icons.cake_outlined,
            onTap: () => _showDatePicker(context, (d) {
              if (d != null) notifier.updateProfile(dateOfBirth: d);
            }),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Gender',
            value: profile.gender ?? '—',
            icon: Icons.wc_outlined,
            onTap: () => _showPicker(context, 'Gender',
              ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
              profile.gender,
              (v) => notifier.updateProfile(gender: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Height',
            value: profile.heightCm != null ? '${profile.heightCm!.toStringAsFixed(0)} cm' : '—',
            icon: Icons.straighten_outlined,
            onTap: () => _showNumberDialog(
              context, 'Height (cm)', profile.heightCm,
              (v) => notifier.updateProfile(heightCm: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Weight',
            value: profile.weightKg != null ? '${profile.weightKg!.toStringAsFixed(0)} kg' : '—',
            icon: Icons.monitor_weight_outlined,
            onTap: () => _showNumberDialog(
              context, 'Weight (kg)', profile.weightKg,
              (v) => notifier.updateProfile(weightKg: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Activity Level',
            value: profile.activityLevel ?? '—',
            icon: Icons.directions_run_outlined,
            onTap: () => _showPicker(context, 'Activity Level',
              ['Sedentary', 'Lightly active', 'Moderately active', 'Very active', 'Extra active'],
              profile.activityLevel,
              (v) => notifier.updateProfile(activityLevel: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Country',
            value: profile.countryCode,
            icon: Icons.public,
            onTap: () => _showPicker(context, 'Country Code',
              ['US', 'FR', 'GB', 'DE', 'JP', 'IN', 'CM', 'CN', 'MX', 'IT'],
              profile.countryCode,
              (v) => notifier.updateProfile(countryCode: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Currency',
            value: profile.currencyCode,
            icon: Icons.attach_money_outlined,
            onTap: () => _showPicker(context, 'Currency Code',
              ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'XAF', 'CNY', 'MXN'],
              profile.currencyCode,
              (v) => notifier.updateProfile(currencyCode: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Cooking Skill',
            value: profile.cookingSkill ?? '—',
            icon: Icons.kitchen_outlined,
            onTap: () => _showPicker(context, 'Cooking Skill',
              ['BEGINNER', 'BALANCED', 'BATCH COOK', 'CHEF MODE'],
              profile.cookingSkill,
              (v) => notifier.updateProfile(cookingSkill: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Household Size',
            value: profile.householdSize != null ? '${profile.householdSize}' : '—',
            icon: Icons.people_outline,
            onTap: () => _showNumberDialog(
              context, 'Household Size', profile.householdSize?.toDouble(),
              (v) => notifier.updateProfile(householdSize: v?.toInt()),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          _EditableRow(
            label: 'Health Goals',
            value: profile.healthGoals?.isNotEmpty == true ? profile.healthGoals! : '—',
            icon: Icons.flag_outlined,
            onTap: () => _showEditDialog(
              context, 'Health Goals', profile.healthGoals ?? '',
              (v) => notifier.updateProfile(healthGoals: v),
            ),
          ),
        ],
      ),
    );
  }

  /// Affiche un dialogue de saisie textuelle.
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

  /// Affiche un dialogue de saisie numérique.
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

  /// Affiche un sélecteur de date.
  void _showDatePicker(BuildContext context, ValueChanged<String?> onSave) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
    ).then((date) {
      if (date != null) {
        onSave(date.toIso8601String().split('T').first);
      }
    });
  }

  /// Affiche un sélecteur par liste d'options.
  void _showPicker(
    BuildContext context,
    String title,
    List<String> options,
    String? current,
    ValueChanged<String> onSave,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: options.map((opt) => RadioListTile<String>(
          title: Text(opt),
          value: opt,
          groupValue: current,
          onChanged: (v) {
            if (v != null) onSave(v);
            Navigator.pop(ctx);
          },
        )).toList(),
      ),
    );
  }
}

/// Ligne éditable avec icône, label et valeur.
class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
  });

  /// Label du champ.
  final String label;
  /// Valeur affichée.
  final String value;
  /// Icône optionnelle.
  final IconData? icon;
  /// Callback de modification.
  final VoidCallback? onTap;

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
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.primaryAccentGreen),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              flex: 2,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textTertiary(context),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 3,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppTypography.bodyLarge.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: PremiumTheme.textTertiary(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Carte de navigation vers un écran.
class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  /// Icône de la carte.
  final IconData icon;
  /// Titre de la carte.
  final String title;
  /// Sous-titre de la carte.
  final String subtitle;
  /// Callback de navigation.
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

/// Sélecteur de thème (clair / système / sombre).
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

/// Bouton de sauvegarde du profil avec détection de changements.
class _SaveProfileButton extends StatelessWidget {
  const _SaveProfileButton({
    required this.hasChanges,
    required this.saving,
    required this.onSave,
  });

  /// Vrai si des modifications non sauvegardées existent.
  final bool hasChanges;
  /// Vrai si la sauvegarde est en cours.
  final bool saving;
  /// Callback de sauvegarde.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    if (!hasChanges && !saving) return const SizedBox.shrink();
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      backgroundColor: AppColors.primaryAccentGreen.withOpacity(0.08),
      borderColor: AppColors.primaryAccentGreen.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasChanges)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primaryAccentGreen,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'You have unsaved changes',
                      style: AppTypography.bodyMedium.copyWith(
                        color: PremiumTheme.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(saving ? 'Saving...' : 'Save All Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccentGreen,
                foregroundColor: PremiumTheme.isDark(context)
                    ? AppColors.darkBackground
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Zone de danger avec déconnexion et suppression de compte.
class _DangerZone extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
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
              onPressed: () {
                authNotifier.logout();
                context.go('/login');
              },
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

  /// Affiche la confirmation de suppression de compte.
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
