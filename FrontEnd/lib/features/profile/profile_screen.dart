import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'widgets/danger_zone.dart';
import 'widgets/profile_completeness.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_navigation_card.dart';
import 'widgets/save_profile_button.dart';
import 'widgets/theme_selector.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadFromApi();
    });
  }

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
                    ProfileHeaderCard(
                      profile: profile,
                      authState: authState,
                      onAvatarTap: _pickImage,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ProfileCompletenessCard(profile: profile),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context, 'Personal Information'),
                    const SizedBox(height: AppSpacing.sm),
                    ProfileInfoCard(profile: profile),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context, 'Food & Preferences'),
                    const SizedBox(height: AppSpacing.sm),
                    ProfileNavigationCard(
                      icon: Icons.restaurant_menu,
                      title: 'Food & Recommendation Preferences',
                      subtitle: 'Diet, allergies, cuisines, goals',
                      onTap: () => context.push('/food-preferences'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ProfileNavigationCard(
                      icon: Icons.payments_outlined,
                      title: 'Budget Management',
                      subtitle: r'$400 weekly grocery cap',
                      onTap: () => context.push('/budget'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ProfileNavigationCard(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English / Français',
                      onTap: () => context.push('/language'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ProfileNavigationCard(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Pantry alerts and plan reminders',
                      onTap: () => context.push('/notification-preferences'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context, 'Appearance'),
                    const SizedBox(height: AppSpacing.sm),
                    const ProfileThemeSelector(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle(context, 'Support'),
                    const SizedBox(height: AppSpacing.sm),
                    ProfileNavigationCard(
                      icon: Icons.help_outline,
                      title: 'Help & FAQ',
                      subtitle: 'Get help and answers',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ProfileNavigationCard(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ProfileNavigationCard(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Legal terms and conditions',
                      onTap: () {},
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SaveProfileButton(
                      hasChanges: hasChanges,
                      saving: _saving,
                      onSave: _saveProfile,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const DangerZoneCard(),
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
