import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_events.dart';
import '../../core/analytics/analytics_service.dart';
import '../../app/theme/app_animations.dart';
import '../../app/theme/app_colors.dart';
import '../../core/design_system/components/pp_card.dart';
import '../../core/design_system/components/pp_scaffold.dart';
import '../../core/design_system/tokens/ds_motion.dart';
import '../../core/design_system/tokens/ds_radius.dart';
import '../../core/design_system/tokens/ds_spacing.dart';
import '../../core/design_system/tokens/ds_typography.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/premium_components.dart';
import '../../core/providers/app_session_provider.dart';
import '../auth/providers/auth_provider.dart';
import 'onboarding_completion.dart';
import 'onboarding_state.dart';
import 'widgets/bottom_cta.dart';
import 'widgets/budget_row.dart';
import 'widgets/cooking_profile_grid.dart';
import 'widgets/cooking_time_segment.dart';
import 'widgets/dietary_chips.dart';
import 'widgets/goal_chips.dart';
import 'widgets/household_grid.dart';
import 'widgets/welcome_header.dart';

const List<String> _householdChoices = ['1', '2', '3', '4+'];
const List<String> _cookingProfiles = [
  'Beginner',
  'Balanced',
  'Batch cook',
  'Chef mode',
];

class OnboardingSingleScreen extends ConsumerStatefulWidget {
  const OnboardingSingleScreen({super.key});

  @override
  ConsumerState<OnboardingSingleScreen> createState() =>
      _OnboardingSingleScreenState();
}

class _OnboardingSingleScreenState
    extends ConsumerState<OnboardingSingleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).track(PlateEvents.onboardingStarted);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final l10n = context.l10n!;
    final isAuthed = ref.watch(authProvider).isAuthenticated;

    return PpScaffold(
      body: Column(
        children: [
          OnboardingWelcomeHeader(onCustomizeLater: _customizeLater),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                DsSpacing.lg,
                DsSpacing.sm,
                DsSpacing.lg,
                DsSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeading(title: l10n.onboardingSingleHousehold),
                  const SizedBox(height: DsSpacing.md),
                  HouseholdSizeGrid(
                    choices: _householdChoices,
                    selected: state.householdSize,
                    onSelected: notifier.setHouseholdSize,
                  ),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleCookingProfile),
                  const SizedBox(height: DsSpacing.md),
                  CookingProfileGrid(
                    choices: _cookingProfiles,
                    selected: state.cookingSkill,
                    onSelected: notifier.setCookingSkill,
                  ),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleBudget),
                  const SizedBox(height: DsSpacing.md),
                  BudgetRow(state: state, notifier: notifier),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleTime),
                  const SizedBox(height: DsSpacing.md),
                  CookingTimeSegment(state: state, notifier: notifier),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleDietary),
                  const SizedBox(height: DsSpacing.md),
                  DietaryChips(state: state, notifier: notifier),
                  const SizedBox(height: DsSpacing.xl),
                  _SectionHeading(title: l10n.onboardingSingleGoals),
                  const SizedBox(height: DsSpacing.md),
                  GoalChips(state: state, notifier: notifier),
                  const SizedBox(height: DsSpacing.xxl),
                  _LivePreviewCard(state: state),
                ],
              ),
            ),
          ),
          OnboardingBottomCta(
            enabled: state.householdSize != null,
            isAuthed: isAuthed,
            onSeePlan: () => _commit(notifier),
            onCreateAccount: () => _commitAndSignup(notifier),
            onSignInInstead: _customizeLater,
          ),
        ],
      ),
    );
  }

  Future<void> _commit(OnboardingNotifier notifier) async {
    HapticFeedback.selectionClick();
    await notifier.flush();
    await ref.read(appSessionProvider.notifier).completeOnboarding();
    await notifier.clearDraft();
    ref
        .read(analyticsServiceProvider)
        .track(PlateEvents.onboardingCompleted);
    if (!mounted) return;
    await OnboardingCompletion.commitAndGeneratePlan(
      ref: ref,
      context: context,
      onSuccess: () {
        if (!mounted) return;
        final isAuthed = ref.read(authProvider).isAuthenticated;
        context.go(isAuthed ? '/home' : '/login');
      },
    );
  }

  Future<void> _commitAndSignup(OnboardingNotifier notifier) async {
    HapticFeedback.selectionClick();
    await notifier.flush();
    if (!mounted) return;
    context.go('/signup');
  }

  Future<void> _customizeLater() async {
    HapticFeedback.selectionClick();
    final isAuthed = ref.read(authProvider).isAuthenticated;
    context.go(isAuthed ? '/home' : '/login');
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: DsTypography.headlineSmall.copyWith(
        color: PremiumTheme.textPrimary(context),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _LivePreviewCard extends StatelessWidget {
  const _LivePreviewCard({required this.state});
  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final isDark = PremiumTheme.isDark(context);
    final hasHousehold = state.householdSize != null;
    final recipesPerWeek = _estimateRecipes(state);
    final budgetLabel = _formatBudget(state);
    final minutesLabel = _formatMinutes(state);

    return AnimatedSwitcher(
      duration: AppMotion.small,
      switchInCurve: AppAnimations.easeOutEmphasized,
      child: PpCard(
        key: ValueKey<String>('preview-$hasHousehold'),
        variant: PpCardVariant.glass,
        padding: const EdgeInsets.all(DsSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccentGreen.withValues(
                      alpha: isDark ? 0.18 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(DsRadius.md),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.primaryAccentGreen,
                  ),
                ),
                const SizedBox(width: DsSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.onboardingSinglePreviewTitle,
                    style: DsTypography.titleMedium.copyWith(
                      color: PremiumTheme.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DsSpacing.md),
            if (!hasHousehold)
              Text(
                l10n.onboardingSinglePreviewEmpty,
                style: DsTypography.bodyMedium.copyWith(
                  color: PremiumTheme.textSecondary(context),
                ),
              )
            else ...[
              _PreviewLine(
                icon: Icons.restaurant_outlined,
                text: l10n.onboardingSinglePreviewRecipes(recipesPerWeek),
              ),
              const SizedBox(height: DsSpacing.xs),
              _PreviewLine(
                icon: Icons.payments_outlined,
                text: l10n.onboardingSinglePreviewBudget(budgetLabel),
              ),
              const SizedBox(height: DsSpacing.xs),
              _PreviewLine(
                icon: Icons.schedule_outlined,
                text: l10n.onboardingSinglePreviewTime(minutesLabel),
              ),
            ],
            const SizedBox(height: DsSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DsSpacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(DsRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: AppColors.primaryAccentGreen,
                  ),
                  const SizedBox(width: DsSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.onboardingSinglePreviewPantryHint,
                      style: DsTypography.bodySmall.copyWith(
                        color: PremiumTheme.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _estimateRecipes(OnboardingState state) {
    final people = int.tryParse(
          (state.householdSize ?? '').replaceAll('+', ''),
        ) ??
        ((state.householdSize ?? '') == '4+' ? 5 : 2);
    final estimate = (people * 3).clamp(5, 21);
    return estimate;
  }

  String _formatBudget(OnboardingState state) {
    if (state.customBudget != null) {
      return '\$${state.customBudget!.toStringAsFixed(0)}';
    }
    final raw = state.weeklyBudget ?? r'$120';
    return raw.isEmpty ? r'$120' : raw;
  }

  int _formatMinutes(OnboardingState state) {
    final raw = state.cookingTime;
    if (raw == null || raw == 'Flexible') return 30;
    final digits = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
    return digits ?? 30;
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryAccentGreen),
        const SizedBox(width: DsSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: DsTypography.bodyMedium.copyWith(
              color: PremiumTheme.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
