import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
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
                      onPressed: () => context.go('/home'),
                    ),
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
