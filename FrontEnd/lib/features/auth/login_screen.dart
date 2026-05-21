import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/providers/app_session_provider.dart';
import '../../core/widgets/social_sign_in_buttons.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PremiumAuthShell(
      mode: _AuthMode.login,
      onSubmit: () async {
        await ref.read(appSessionProvider.notifier).signIn();
        if (context.mounted) context.go('/home');
      },
    );
  }
}

class _PremiumAuthShell extends StatefulWidget {
  const _PremiumAuthShell({required this.mode, required this.onSubmit});

  final _AuthMode mode;
  final Future<void> Function() onSubmit;

  @override
  State<_PremiumAuthShell> createState() => _PremiumAuthShellState();
}

class _PremiumAuthShellState extends State<_PremiumAuthShell> {
  bool _passwordVisible = false;

  bool get _isSignup => widget.mode == _AuthMode.signup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _BrandMark(isCompact: false),
                    const SizedBox(height: AppSpacing.lg),
                    GlassContainer(
                      borderRadius: AppRadius.xxl,
                      elevated: true,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isSignup
                                ? 'Create your account'
                                : 'Sign in to your account',
                            style: AppTypography.headlineMedium.copyWith(
                              color: PremiumTheme.textPrimary(context),
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const SocialSignInButtons(),
                          const SizedBox(height: AppSpacing.lg),
                          if (_isSignup) ...[
                            const GlassTextField(
                              labelText: 'Full name',
                              hintText: 'Enter your name',
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          const GlassTextField(
                            labelText: 'Email address',
                            hintText: 'name@example.com',
                            prefixIcon: Icons.mail_outline,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GlassTextField(
                            labelText: 'Password',
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !_passwordVisible,
                            suffixIcon: IconButton(
                              tooltip: _passwordVisible
                                  ? 'Hide password'
                                  : 'Show password',
                              onPressed: () => setState(
                                () => _passwordVisible = !_passwordVisible,
                              ),
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                          if (!_isSignup) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.go('/forgot-password'),
                                child: const Text('Forgot password?'),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          GlassButton(
                            label: _isSignup ? 'Sign Up' : 'Continue',
                            icon: Icons.arrow_forward,
                            onPressed: widget.onSubmit,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: () => context.go(
                              _isSignup ? '/login' : '/signup',
                            ),
                            child: Text(
                              _isSignup
                                  ? 'Already have an account? Sign in'
                                  : 'Do not have an account? Sign up',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'By continuing, you agree to PlatePilot terms and privacy policy.',
                      style: AppTypography.bodySmall.copyWith(
                        color: PremiumTheme.textTertiary(context),
                      ),
                      textAlign: TextAlign.center,
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

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: isCompact ? 54 : 66,
          height: isCompact ? 54 : 66,
          decoration: BoxDecoration(
            color: AppColors.premiumCyanAccent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: PremiumTheme.glow(
              context,
              color: AppColors.premiumCyanAccent,
            ),
          ),
          child: Icon(
            Icons.restaurant_menu,
            color:
                PremiumTheme.isDark(context) ? AppColors.darkBackground : Colors.white,
            size: isCompact ? 28 : 34,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'PlatePilot',
          style: AppTypography.displayLarge.copyWith(
            color: PremiumTheme.textPrimary(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Intelligent meal planning for a calmer kitchen.',
          style: AppTypography.bodyMedium.copyWith(
            color: PremiumTheme.textSecondary(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

enum _AuthMode { login, signup }

class PremiumSignupScreen extends ConsumerWidget {
  const PremiumSignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PremiumAuthShell(
      mode: _AuthMode.signup,
      onSubmit: () async {
        await ref.read(appSessionProvider.notifier).signIn();
        if (context.mounted) context.go('/home');
      },
    );
  }
}
