import 'package:flutter/material.dart';

import '../../../core/design_system/components/pp_button.dart';
import '../../../core/design_system/tokens/ds_spacing.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/premium_components.dart';

class OnboardingBottomCta extends StatelessWidget {
  const OnboardingBottomCta({
    super.key,
    required this.enabled,
    required this.isAuthed,
    required this.onSeePlan,
    required this.onCreateAccount,
    required this.onSignInInstead,
  });

  final bool enabled;
  final bool isAuthed;
  final VoidCallback onSeePlan;
  final VoidCallback onCreateAccount;
  final VoidCallback onSignInInstead;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        DsSpacing.lg,
        DsSpacing.md,
        DsSpacing.lg,
        DsSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: PremiumTheme.background(context),
        border: Border(
          top: BorderSide(color: PremiumTheme.border(context)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: isAuthed
            ? PpButton(
                label: l10n.onboardingSingleCtaSeePlan,
                icon: Icons.arrow_forward,
                onPressed: enabled ? onSeePlan : null,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PpButton(
                    label: l10n.onboardingSingleCtaCreateAccount,
                    icon: Icons.rocket_launch_outlined,
                    onPressed: enabled ? onCreateAccount : null,
                  ),
                  const SizedBox(height: DsSpacing.sm),
                  PpButton(
                    label: l10n.onboardingSingleCtaSignInInstead,
                    variant: PpButtonVariant.ghost,
                    icon: Icons.login,
                    onPressed: onSignInInstead,
                  ),
                ],
              ),
      ),
    );
  }
}
