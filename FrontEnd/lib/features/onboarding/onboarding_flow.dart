import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/premium_components.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_single_screen.dart';

const double _kCustomBudgetMin = 20;
const double _kCustomBudgetMax = 500;

/// Legacy alias — la version "single-screen scroll-to-commit" remplace
/// désormais le multi-step historique. Conservé temporairement pour ne
/// pas casser les imports externes le temps de la migration.
///
/// @deprecated Utiliser [OnboardingSingleScreen] directement.
class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context) => const OnboardingSingleScreen();
}

/// Ouvre un bottom sheet avec slider + input numérique pour
/// saisir un budget personnalisé (range $20–$500).
///
/// Conservé ici pour rétro-compatibilité avec les appelants historiques.
Future<double?> showCustomBudgetSheet(
  BuildContext context, {
  double? initial,
  AppLocalizations? l10n,
}) {
  final locale = l10n ?? context.l10n;
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => _CustomBudgetSheet(
      initial: initial ?? 120,
      l10n: locale,
    ),
  );
}

/// Bottom sheet persistée pour rétro-compatibilité (utilisée par
/// `showCustomBudgetSheet`). L'UI du single-screen ne référence que
/// `showCustomBudgetSheet`.
class _CustomBudgetSheet extends StatefulWidget {
  const _CustomBudgetSheet({required this.initial, required this.l10n});

  final double initial;
  final AppLocalizations l10n;

  @override
  State<_CustomBudgetSheet> createState() => _CustomBudgetSheetState();
}

class _CustomBudgetSheetState extends State<_CustomBudgetSheet> {
  late final TextEditingController _controller;
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial.clamp(_kCustomBudgetMin, _kCustomBudgetMax);
    _controller = TextEditingController(text: _value.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncFromSlider(double v) {
    setState(() {
      _value = v;
      _controller.text = v.toStringAsFixed(0);
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  void _syncFromText(String raw) {
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null) return;
    final clamped = parsed.clamp(_kCustomBudgetMin, _kCustomBudgetMax);
    setState(() {
      _value = clamped;
      if (clamped.toStringAsFixed(0) != raw) {
        _controller.text = clamped.toStringAsFixed(0);
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.l10n.customBudgetTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: PremiumTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.l10n.customBudgetSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: PremiumTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  r'$',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: _value.toStringAsFixed(0),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: _syncFromText,
                    onSubmitted: (_) => Navigator.of(context).pop(_value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Slider(
              value: _value,
              min: _kCustomBudgetMin,
              max: _kCustomBudgetMax,
              divisions: (_kCustomBudgetMax - _kCustomBudgetMin).toInt(),
              label: '\$${_value.toStringAsFixed(0)}',
              activeColor: AppColors.primaryAccentGreen,
              onChanged: _syncFromSlider,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${_kCustomBudgetMin.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
                  Text(
                    '\$${_kCustomBudgetMax.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: GlassOutlinedButton(
                    label: widget.l10n.backBtn,
                    icon: Icons.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GlassButton(
                    label: widget.l10n.continueBtn,
                    icon: Icons.check,
                    onPressed: () => Navigator.of(context).pop(_value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Ré-export du single-screen sous l'alias historique — évite une
// régression silencieuse si certains imports historiques s'attendent
// toujours à voir un widget nommé "OnboardingFlow".
typedef OnboardingStepper = OnboardingSingleScreen;
