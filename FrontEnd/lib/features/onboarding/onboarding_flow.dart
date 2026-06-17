import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/premium_components.dart';
import '../../core/providers/app_session_provider.dart';
import '../../l10n/app_localizations.dart';
import '../preferences/preferences_provider.dart';
import 'onboarding_state.dart';

const double _kCustomBudgetMin = 20;
const double _kCustomBudgetMax = 500;

/// Écran principal du parcours d'onboarding en 3 étapes.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  /// Étape courante (0, 1 ou 2).
  late int step;

  @override
  void initState() {
    super.initState();
    step = ref.read(onboardingProvider).currentStep;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final canContinue = switch (step) {
      0 => state.canContinueStepOne,
      1 => state.canContinueStepTwo,
      _ => state.canContinueStepThree,
    };
    final l10n = context.l10n;

    return Scaffold(
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          child: Column(
            children: [
              const FloatingHeader(title: 'PlatePilot'),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: _ProgressHeader(
                  step: step,
                  label: _stepLabel(context, step),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInOut,
                  child: SingleChildScrollView(
                    key: ValueKey(step),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    child: _buildStep(context, state, notifier, l10n),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    GlassButton(
                      label: step == 2 ? l10n.doneBtn : l10n.continueBtn,
                      icon: Icons.arrow_forward,
                      onPressed: canContinue ? _continue : null,
                    ),
                    if (step > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      GlassOutlinedButton(
                        label: l10n.backBtn,
                        icon: Icons.arrow_back,
                        onPressed: () {
                          setState(() => step -= 1);
                          ref
                              .read(onboardingProvider.notifier)
                              .setCurrentStep(step);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Passe à l'étape suivante ou termine l'onboarding.
  Future<void> _continue() async {
    HapticFeedback.selectionClick();
    if (step == 2) {
      await ref.read(onboardingProvider.notifier).flush();
      await ref.read(appSessionProvider.notifier).completeOnboarding();
      await ref.read(onboardingProvider.notifier).clearDraft();
      if (!mounted) return;
      final after = GoRouterState.of(context).uri.queryParameters['after'];
      context.go(after == 'signup' ? '/signup' : '/login');
      return;
    }
    setState(() => step += 1);
    ref.read(onboardingProvider.notifier).setCurrentStep(step);
  }

  /// Construit le contenu de l'étape courante.
  Widget _buildStep(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
    AppLocalizations l10n,
  ) {
    return switch (step) {
      0 => _OnboardingStep(
          title: l10n.step1Title,
          subtitle: l10n.step1Subtitle,
          children: [
            _ChoiceGrid(
              title: l10n.householdSize,
              choices: const ['1', '2', '3', '4+'],
              selectedValues: {
                if (state.householdSize != null) state.householdSize!,
              },
              onSelected: notifier.setHouseholdSize,
            ),
            _ChoiceGrid(
              title: l10n.cookingProfile,
              choices: const ['Beginner', 'Balanced', 'Batch cook', 'Chef mode'],
              selectedValues: {
                if (state.cookingSkill != null) state.cookingSkill!,
              },
              onSelected: notifier.setCookingSkill,
            ),
          ],
        ),
      1 => _OnboardingStep(
          title: l10n.step2Title,
          subtitle: l10n.step2Subtitle,
          children: [
            _ChoiceGrid(
              title: l10n.weeklyBudget,
              choices: const [r'$75', r'$120', r'$180', 'Custom'],
              selectedValues: {
                if (state.weeklyBudget != null &&
                    state.weeklyBudget != 'Custom')
                  state.weeklyBudget!,
                if (state.customBudget != null) state.customBudget!.toStringAsFixed(0),
              },
              onSelected: (value) async {
                if (value == 'Custom') {
                  final picked = await showCustomBudgetSheet(
                    context,
                    initial: state.customBudget,
                    l10n: l10n,
                  );
                  if (picked != null) {
                    notifier.setCustomBudget(picked);
                    ref
                        .read(editablePreferencesProvider.notifier)
                        .setWeeklyBudget(picked.toStringAsFixed(0));
                  } else {
                    notifier.setWeeklyBudget('Custom');
                  }
                } else {
                  notifier.setWeeklyBudget(value);
                }
              },
              customValueBuilder: () {
                if (state.customBudget != null) {
                  return '\$${state.customBudget!.toStringAsFixed(0)}';
                }
                return null;
              },
            ),
            _ChoiceGrid(
              title: l10n.cookingTime,
              choices: const ['15 min', '30 min', '45 min', 'Flexible'],
              selectedValues: {
                if (state.cookingTime != null) state.cookingTime!,
              },
              onSelected: notifier.setCookingTime,
            ),
            _ChoiceGrid(
              title: l10n.dietaryPrefs,
              choices: const [
                'High protein',
                'Vegetarian',
                'Gluten-free',
                'Low carb',
              ],
              selectedValues: state.dietaryPreferences,
              onSelected: notifier.toggleDietaryPreference,
              multiSelect: true,
            ),
          ],
        ),
      _ => _OnboardingStep(
          title: l10n.step3Title,
          subtitle: l10n.step3Subtitle,
          children: [
            _ChoiceGrid(
              title: l10n.goals,
              choices: const [
                'Save money',
                'Eat healthier',
                'Waste less',
                'Cook faster',
              ],
              selectedValues: state.goals,
              onSelected: notifier.toggleGoal,
              multiSelect: true,
            ),
            PremiumCard(
              variant: PremiumCardVariant.glass,
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primaryAccentGreen,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.pantryLater,
                      style: AppTypography.bodyMedium.copyWith(
                        color: PremiumTheme.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    };
  }

  /// Ouvre un [showModalBottomSheet] avec slider + input numérique pour
  /// saisir un budget personnalisé (range $20–$500).
}

/// Ouvre un bottom sheet avec slider + input numérique pour
/// saisir un budget personnalisé (range $20–$500).
Future<double?> showCustomBudgetSheet(
  BuildContext context, {
  double? initial,
  required AppLocalizations l10n,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => _CustomBudgetSheet(
      initial: initial ?? 120,
      l10n: l10n,
    ),
  );
}

/// Libellé de l'étape courante.
String _stepLabel(BuildContext context, int step) {
  final l10n = context.l10n;
  return switch (step) {
    0 => l10n.householdSetup,
    1 => l10n.budgetConstraints,
    _ => l10n.goalsPantry,
  };
}

/// En-tête de progression avec barre de progression animée.
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.step, required this.label});

  /// Étape courante (0-indexée).
  final int step;
  /// Libellé de l'étape.
  final String label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.stepOf(step + 1, 3),
              style: AppTypography.bodyMedium.copyWith(
                color: PremiumTheme.textSecondary(context),
              ),
            ),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primaryAccentGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedProgressBar(value: (step + 1) / 3),
      ],
    );
  }
}

/// Une étape de l'onboarding avec titre, sous-titre et contenu.
class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  /// Titre de l'étape.
  final String title;
  /// Sous-titre de l'étape.
  final String subtitle;
  /// Liste des widgets enfants.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          style: AppTypography.displaySmall.copyWith(
            color: PremiumTheme.textPrimary(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: PremiumTheme.textSecondary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...children,
      ],
    );
  }
}

/// Grille de choix pour une question de l'onboarding.
class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.title,
    required this.choices,
    required this.selectedValues,
    required this.onSelected,
    this.multiSelect = false,
    this.customValueBuilder,
  });

  /// Titre de la question.
  final String title;
  /// Liste des options disponibles.
  final List<String> choices;
  /// Ensemble des valeurs sélectionnées.
  final Set<String> selectedValues;
  /// Callback de sélection.
  final ValueChanged<String> onSelected;
  /// Vrai si la sélection multiple est autorisée.
  final bool multiSelect;
  /// Optionnel : libellé custom pour les choix spéciaux (ex: budget perso).
  final String? Function()? customValueBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: PremiumTheme.textPrimary(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.25,
            ),
            itemCount: choices.length,
            itemBuilder: (context, index) {
              final value = choices[index];
              final isCustomTrigger = value == 'Custom';
              final customLabel = isCustomTrigger ? customValueBuilder?.call() : null;
              final displayLabel = customLabel ?? value;
              final selected = isCustomTrigger
                  ? customLabel != null
                  : selectedValues.contains(value);
              return SelectableGlassCard(
                selected: selected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(value);
                },
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: '${l10n.custom} : $displayLabel',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (multiSelect && selected) ...[
                        const Icon(Icons.check_circle, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Flexible(
                        child: Text(
                          displayLabel,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: isCustomTrigger && selected
                              ? AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primaryAccentGreen,
                                  fontWeight: FontWeight.w700,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet permettant de saisir un budget personnalisé (slider + champ).
class _CustomBudgetSheet extends StatefulWidget {
  const _CustomBudgetSheet({
    required this.initial,
    required this.l10n,
  });

  /// Valeur initiale du slider.
  final double initial;

  /// Localizations.
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
              style: AppTypography.headlineSmall.copyWith(
                color: PremiumTheme.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.l10n.customBudgetSubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: PremiumTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  r'$',
                  style: AppTypography.displaySmall.copyWith(
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    style: AppTypography.displaySmall.copyWith(
                      color: PremiumTheme.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: _value.toStringAsFixed(0),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppTypography.displaySmall.copyWith(
                        color: PremiumTheme.textSecondary(context)
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    onChanged: _syncFromText,
                    onSubmitted: (_) =>
                        Navigator.of(context).pop(_value),
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
                    style: AppTypography.labelSmall.copyWith(
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
                  Text(
                    '\$${_kCustomBudgetMax.toStringAsFixed(0)}',
                    style: AppTypography.labelSmall.copyWith(
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
