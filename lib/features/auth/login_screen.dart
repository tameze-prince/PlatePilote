import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/providers/app_session_provider.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AuthShell(
      title: 'Welcome back',
      subtitle: 'Sign in to keep your weekly plan and grocery list in sync.',
      action: 'Sign In',
      footer: 'Create Account',
      onAction: () async {
        await ref.read(appSessionProvider.notifier).signIn();
        if (context.mounted) {
          context.go('/home');
        }
      },
      onFooter: () => context.go('/signup'),
    );
  }
}

class _AuthShell extends StatelessWidget {
  const _AuthShell({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.footer,
    required this.onAction,
    required this.onFooter,
  });

  final String title;
  final String subtitle;
  final String action;
  final String footer;
  final VoidCallback onAction;
  final VoidCallback onFooter;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  Container(
                    width: isTablet ? 80 : 64,
                    height: isTablet ? 80 : 64,
                    decoration: BoxDecoration(
                      color: ColorTokens.primaryGreen,
                      borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: isTablet ? 44 : 34,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('PlatePilot', style: context.text.displaySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your intelligent co-pilot for meal planning and grocery organization.',
                    style: context.text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.text.headlineMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(subtitle, style: context.text.bodyMedium),
                        const SizedBox(height: AppSpacing.lg),
                        const TextField(
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'name@example.com',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '••••••••',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(label: action, onPressed: onAction),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed: onFooter,
                            child: Text(footer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
