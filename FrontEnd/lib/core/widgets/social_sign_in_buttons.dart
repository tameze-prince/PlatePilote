import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/premium_components.dart';
import '../../core/providers/app_session_provider.dart';

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
          onTap: () => _signInWithProvider(ref, context, 'Google'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SocialButton(
          icon: Icons.apple,
          label: 'Sign in with Apple',
          onTap: () => _signInWithProvider(ref, context, 'Apple'),
        ),
      ],
    );
  }

  Future<void> _signInWithProvider(
    WidgetRef ref,
    BuildContext context,
    String provider,
  ) async {
    await ref.read(appSessionProvider.notifier).signIn();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed in with $provider'),
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
        context.isDark ? ColorTokens.darkBorder : ColorTokens.border;
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
