import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/premium_components.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Boutons de connexion sociale (Google, Apple) avec séparateur "or continue with".
class SocialSignInButtons extends ConsumerWidget {
  const SocialSignInButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('or continue with', style: context.text.bodyMedium),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _SocialButton(
          icon: Icons.g_mobiledata,
          label: 'Sign in with Google',
          onTap: () => _signInWithGoogle(ref, context),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SocialButton(
          icon: Icons.apple,
          label: 'Sign in with Apple',
          onTap: () => _signInWithApple(ref, context),
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final success = await ref.read(authProvider.notifier).signInWithGoogle();
    if (success && context.mounted) {
      context.go('/home');
    } else if (context.mounted) {
      final error = ref.read(authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Google sign-in failed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signInWithApple(WidgetRef ref, BuildContext context) async {
    final success = await ref.read(authProvider.notifier).signInWithApple();
    if (success && context.mounted) {
      context.go('/home');
    } else if (context.mounted) {
      final error = ref.read(authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Apple sign-in failed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        context.isDark ? AppColors.darkOutline : AppColors.outline;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: GlassContainer(
          borderRadius: AppRadius.full,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shadows: const [],
          backgroundColor: PremiumTheme.glass(context),
          borderColor: borderColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: context.text.bodyLarge?.color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: context.text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
