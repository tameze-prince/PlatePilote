import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/premium_components.dart';
import '../../auth/providers/auth_state.dart';
import '../providers/profile_provider.dart';

/// Carte d'en-tête du profil avec avatar et informations utilisateur.
class ProfileHeaderCard extends ConsumerWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.authState,
    required this.onAvatarTap,
  });

  /// Profil utilisateur observé.
  final UserProfile profile;
  /// État d'authentification courant.
  final AuthState authState;
  /// Callback invoqué au tap sur l'avatar.
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
                  backgroundColor: AppColors.primaryAccentGreen.withValues(alpha: 0.2),
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
              color: AppColors.primaryAccentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: AppColors.primaryAccentGreen.withValues(alpha: 0.3),
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
