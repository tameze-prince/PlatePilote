import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import '../../core/widgets/social_sign_in_buttons.dart';
import '../onboarding/onboarding_state.dart';
import 'providers/auth_provider.dart';
import 'providers/auth_state.dart';

/// Écran de connexion à l'application.
/// Permet à l'utilisateur de se connecter avec email et mot de passe.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// Contrôleur pour le champ email.
  final _emailController = TextEditingController();

  /// Contrôleur pour le champ mot de passe.
  final _passwordController = TextEditingController();

  /// Clé globale pour la validation du formulaire.
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Soumet le formulaire de connexion.
  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.errorMessage;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    return _PremiumAuthShell(
      isLoading: isLoading,
      errorMessage: errorMessage,
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      onSubmit: _onSubmit,
      onSwitchAuthMode: () {
        ref.read(onboardingProvider.notifier).reset();
        context.go('/onboarding?after=signup');
      },
    );
  }
}

/// Écran d'inscription premium.
/// Permet à l'utilisateur de créer un compte avec nom, email et mot de passe.
class PremiumSignupScreen extends ConsumerStatefulWidget {
  const PremiumSignupScreen({super.key});

  @override
  ConsumerState<PremiumSignupScreen> createState() => _PremiumSignupScreenState();
}

class _PremiumSignupScreenState extends ConsumerState<PremiumSignupScreen> {
  /// Contrôleur pour le champ du nom complet.
  final _nameController = TextEditingController();

  /// Contrôleur pour le champ email.
  final _emailController = TextEditingController();

  /// Contrôleur pour le champ mot de passe.
  final _passwordController = TextEditingController();

  /// Clé globale pour la validation du formulaire.
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Soumet le formulaire d'inscription.
  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final parts = name.split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : firstName;

    final success = await ref.read(authProvider.notifier).register(
      firstName: firstName,
      lastName: lastName,
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/verify-email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.errorMessage;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    return _PremiumAuthShell(
      isSignup: true,
      isLoading: isLoading,
      errorMessage: errorMessage,
      formKey: _formKey,
      nameController: _nameController,
      emailController: _emailController,
      passwordController: _passwordController,
      onSubmit: _onSubmit,
      onSwitchAuthMode: () => context.go('/login'),
    );
  }
}

/// Shell d'authentification premium réutilisable.
/// Affiche le formulaire de connexion ou d'inscription avec un design premium.
class _PremiumAuthShell extends StatefulWidget {
  const _PremiumAuthShell({
    this.isSignup = false,
    this.isLoading = false,
    this.errorMessage,
    required this.formKey,
    this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    this.onSwitchAuthMode,
  });

  /// Mode inscription (true) ou connexion (false).
  final bool isSignup;

  /// Indique si une opération est en cours.
  final bool isLoading;

  /// Message d'erreur à afficher.
  final String? errorMessage;

  /// Clé globale du formulaire.
  final GlobalKey<FormState> formKey;

  /// Contrôleur pour le champ du nom (inscription uniquement).
  final TextEditingController? nameController;

  /// Contrôleur pour le champ email.
  final TextEditingController emailController;

  /// Contrôleur pour le champ mot de passe.
  final TextEditingController passwordController;

  /// Callback de soumission du formulaire.
  final Future<void> Function() onSubmit;

  /// Callback pour basculer entre connexion et inscription.
  final VoidCallback? onSwitchAuthMode;

  @override
  State<_PremiumAuthShell> createState() => _PremiumAuthShellState();
}

class _PremiumAuthShellState extends State<_PremiumAuthShell> {
  /// Indique si le mot de passe est visible.
  bool _passwordVisible = false;

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
                child: Form(
                  key: widget.formKey,
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
                              widget.isSignup
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
                            if (widget.isSignup) ...[
                              GlassTextField(
                                labelText: 'Full name',
                                hintText: 'Enter your name',
                                prefixIcon: Icons.person_outline,
                                controller: widget.nameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            GlassTextField(
                              labelText: 'Email address',
                              hintText: 'name@example.com',
                              prefixIcon: Icons.mail_outline,
                              controller: widget.emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            GlassTextField(
                              labelText: 'Password',
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              controller: widget.passwordController,
                              obscureText: !_passwordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (widget.isSignup && value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
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
                            if (!widget.isSignup) ...[
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
                              label: widget.isLoading
                                  ? 'Please wait...'
                                  : (widget.isSignup ? 'Sign Up' : 'Continue'),
                              icon: widget.isLoading ? null : Icons.arrow_forward,
                              onPressed: widget.isLoading ? null : widget.onSubmit,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: widget.isLoading
                                  ? null
                                  : widget.onSwitchAuthMode,
                              child: Text(
                                widget.isSignup
                                    ? 'Already have an account? Sign in'
                                    : 'Create new account',
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
      ),
    );
  }
}

/// Marque visuelle de PlatePilot (logo + nom + tagline).
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.isCompact});

  /// Mode compact (true) ou normal (false).
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
