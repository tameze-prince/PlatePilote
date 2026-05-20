import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/color_tokens.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isResending = false;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (context.mounted) {
      context.go('/home');
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isResending = false;
      _resendCooldown = 60;
    });
    _startCooldown();
  }

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
                      color: ColorTokens.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.modal),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread,
                      color: ColorTokens.primaryGreen,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Verify Your Email',
                    style: context.text.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'We sent a verification code to\nyour email address',
                    style: context.text.bodyMedium?.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        _buildCodeInput(),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: 'Verify Email',
                          onPressed: _verifyCode,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SecondaryButton(
                          label: _resendCooldown > 0
                              ? 'Resend in $_resendCooldown s'
                              : 'Resend Code',
                          onPressed:
                              _resendCooldown > 0 || _isResending
                                  ? null
                                  : _resendCode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to Sign In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Code',
          style: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: context.text.headlineMedium?.copyWith(
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: context.text.headlineMedium?.copyWith(
              color: ColorTokens.textSecondary.withOpacity(0.3),
              letterSpacing: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: ColorTokens.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: ColorTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(
                color: ColorTokens.primaryGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
            ),
          ),
          maxLength: 6,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              null,
        ),
      ],
    );
  }
}
