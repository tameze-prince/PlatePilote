import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/providers/app_session_provider.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/social_sign_in_buttons.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 560 : 440),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your PlatePilot account',
                      style: context.text.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Personalized meal planning starts with a few basics.',
                      style: context.text.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Email Address'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: 'Create Account',
                      onPressed: () async {
                        await ref.read(appSessionProvider.notifier).signIn();
                        if (context.mounted) {
                          context.go('/home');
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const SocialSignInButtons(),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('I already have an account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
