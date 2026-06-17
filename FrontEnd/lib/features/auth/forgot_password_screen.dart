import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/repositories/auth_repository.dart';

/// Écran de mot de passe oublié.
/// Permet à l'utilisateur de demander un lien de réinitialisation par email.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  /// Contrôleur pour le champ email.
  final _emailController = TextEditingController();

  /// Clé globale pour la validation du formulaire.
  final _formKey = GlobalKey<FormState>();

  /// Indique si la requête est en cours.
  bool _isLoading = false;

  /// Indique si l'email a été envoyé avec succès.
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Envoie le lien de réinitialisation à l'adresse email saisie.
  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.forgotPassword(_emailController.text.trim());
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.modal),
                    ),
                    child: Icon(
                      _emailSent ? Icons.check_circle : Icons.lock_reset,
                      color: _emailSent
                          ? AppColors.primaryLight
                          : AppColors.secondary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _emailSent ? 'Check Your Email' : 'Reset Password',
                    style: context.text.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _emailSent
                        ? 'We sent a password reset link to\n${_emailController.text}'
                        : 'Enter your email and we\'ll send you\na reset link',
                    style: context.text.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_emailSent) ...[
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                hintText: 'name@example.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.input,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PrimaryButton(
                              label: 'Send Reset Link',
                              onPressed: _isLoading ? null : _sendResetLink,
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.input,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppColors.primaryLight,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      'If an account exists, you\'ll receive an email shortly.',
                                      style: context.text.bodySmall?.copyWith(
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PrimaryButton(
                              label: 'Back to Sign In',
                              onPressed: () => context.go('/login'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!_emailSent) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Back to Sign In'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
