import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/premium_components.dart';
import 'providers/auth_provider.dart';

/// Écran de vérification d'email.
/// Permet à l'utilisateur de saisir un token de vérification ou d'utiliser
/// celui passé en paramètre pour valider son adresse email.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key, this.token});

  /// Token de vérification optionnel fourni via un lien.
  final String? token;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  /// Contrôleur pour le champ du token de vérification.
  final _tokenController = TextEditingController();

  /// Indique si une vérification est en cours.
  bool _isVerifying = false;

  /// Indique si un renvoi de code est en cours.
  bool _isResending = false;

  /// Temps restant avant de pouvoir renvoyer un email (en secondes).
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    if (widget.token != null && widget.token!.isNotEmpty) {
      _tokenController.text = widget.token!;
      _verifyToken();
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  /// Vérifie le token saisi auprès du serveur.
  Future<void> _verifyToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    setState(() => _isVerifying = true);

    final success = await ref.read(authProvider.notifier).verifyEmail(token);

    if (mounted) {
      setState(() => _isVerifying = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email verified successfully!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Verification failed. Check the token and try again.',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  /// Renvoie un email de vérification à l'utilisateur.
  Future<void> _resendCode() async {
    final email = ref.read(authProvider).email;
    if (email == null) return;

    setState(() => _isResending = true);

    final success =
        await ref.read(authProvider.notifier).resendVerification(email: email);

    if (mounted) {
      setState(() {
        _isResending = false;
        if (success) {
          _resendCooldown = 60;
          _startCooldown();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Verification email sent!'),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      });
    }
  }

  /// Lance le compte à rebours avant le prochain renvoi autorisé.
  void _startCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        _startCooldown();
      }
    });
  }

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
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                      ),
                      child: const Icon(
                        Icons.mark_email_unread,
                        color: AppColors.primaryAccentGreen,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Verify Your Email',
                      style: AppTypography.headlineMedium.copyWith(
                        color: PremiumTheme.textPrimary(context),
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'We sent a verification link to your email.\n'
                      'Paste the token below or click the link in the email.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: PremiumTheme.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GlassContainer(
                      borderRadius: AppRadius.xxl,
                      elevated: true,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          GlassTextField(
                            labelText: 'Verification Token',
                            hintText: 'Paste your verification token here',
                            controller: _tokenController,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          GlassButton(
                            label: _isVerifying ? 'Verifying...' : 'Verify Email',
                            onPressed:
                                (_isVerifying || _tokenController.text.trim().isEmpty)
                                    ? null
                                    : _verifyToken,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GlassButton(
                            label: _isResending
                                ? 'Sending...'
                                : (_resendCooldown > 0
                                    ? 'Resend in $_resendCooldown s'
                                    : 'Resend Verification Email'),
                            onPressed:
                                (_resendCooldown > 0 || _isResending) ? null : _resendCode,
                            variant: GlassButtonVariant.outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Back to Sign In',
                        style: TextStyle(
                          color: PremiumTheme.textSecondary(context),
                        ),
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
