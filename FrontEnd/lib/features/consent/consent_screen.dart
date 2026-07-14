import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/providers/app_session_provider.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _analyticsAccepted = false;
  bool _pushAccepted = false;
  bool _isSaving = false;

  Future<void> _continue() async {
    if (!_analyticsAccepted || _isSaving) return;
    setState(() => _isSaving = true);
    await ref
        .read(appSessionProvider.notifier)
        .acceptBetaConsent(pushConsent: _pushAccepted);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textColor = isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkOutline
                        : AppColors.outlineVariant,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        size: 36,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Before you start',
                        style: AppTypography.headlineMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'PlatePilot respects your privacy. During the beta, anonymized usage statistics are required so we can detect issues, improve core flows, and prepare a reliable public launch.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkOnSurfaceVariant
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CheckboxListTile(
                        value: _analyticsAccepted,
                        onChanged: (value) => setState(
                          () => _analyticsAccepted = value ?? false,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          'I accept anonymized beta analytics',
                        ),
                        subtitle: const Text(
                          'No recipes, photos, payment details, or food preferences are sold. Analytics can be revoked from Settings.',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        value: _pushAccepted,
                        onChanged: (value) => setState(
                          () => _pushAccepted = value ?? false,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Enable app push reminders'),
                        subtitle: const Text(
                          'Optional. The Android/iOS system prompt may ask again later.',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed:
                              _analyticsAccepted && !_isSaving ? _continue : null,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward),
                          label: const Text('Continue to PlatePilot'),
                        ),
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
