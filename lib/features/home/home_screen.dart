import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/budget_meter.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/meal_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/savings_card.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/plate_scaffold.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return PlateScaffold(
      title: 'PlatePilot',
      child: _isLoading
          ? ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const [
                LoadingSkeleton(height: 28, width: 240),
                SizedBox(height: AppSpacing.md),
                LoadingSkeleton(height: 18, width: 200),
                SizedBox(height: AppSpacing.lg),
                LoadingSkeletonCard(),
                SizedBox(height: AppSpacing.md),
                LoadingSkeletonCard(),
                SizedBox(height: AppSpacing.md),
                LoadingSkeletonCard(),
              ],
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text(
                    'Good morning, Sarah!',
                    style: context.text.headlineLarge?.copyWith(
                      fontSize: isTablet ? 32 : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Ready to stay on track and save today?',
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _StreakBar(streak: 7, mealsPlanned: 21, wasteSaved: 3),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cards = [
                        const SavingsCard(),
                        const AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _BudgetHeader(),
                              SizedBox(height: AppSpacing.md),
                              BudgetMeter(
                                progress: 0.64,
                                caption: r'$256.00 remaining of $400.00',
                              ),
                            ],
                          ),
                        ),
                      ];
                      if (constraints.maxWidth > 560) {
                        return Row(
                          children: cards
                              .map(
                                (card) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.md,
                                    ),
                                    child: card,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }
                      return Column(
                        children: cards
                            .map(
                              (card) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: card,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Your Plan for Today',
                                style: context.text.headlineMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/plan'),
                              child: const Text('View Full Plan'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...todayMeals.map(
                          (meal) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: MealCard(
                              meal: meal,
                              compact: true,
                              onTap: () => context.push('/recipe/0'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    color: ColorTokens.error.withValues(
                      alpha: context.isDark ? 0.16 : 0.08,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: ColorTokens.error,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Spinach and Greek yogurt should be used this week.',
                            style: context.text.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Quick Meal Mode',
                    icon: Icons.bolt,
                    onPressed: () => context.push('/quick-meal'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StreakBar extends StatelessWidget {
  const _StreakBar({
    required this.streak,
    required this.mealsPlanned,
    required this.wasteSaved,
  });

  final int streak;
  final int mealsPlanned;
  final int wasteSaved;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return AppCard(
      child: Row(
        children: [
          _StreakStat(
            icon: Icons.local_fire_department,
            value: '$streak',
            label: 'Day streak',
            color: ColorTokens.accentAmber,
          ),
          if (isTablet) ...[
            const SizedBox(width: AppSpacing.md),
            _StreakStat(
              icon: Icons.restaurant,
              value: '$mealsPlanned',
              label: 'Meals',
              color: ColorTokens.primaryGreen,
            ),
          ],
          const SizedBox(width: AppSpacing.md),
          _StreakStat(
            icon: Icons.recycling,
            value: '$wasteSaved',
            label: 'Waste saved',
            color: ColorTokens.accentBlue,
          ),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  const _StreakStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.micro),
          Text(
            value,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(label, style: context.text.bodyMedium),
        ],
      ),
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget Status', style: context.text.labelSmall),
              const SizedBox(height: AppSpacing.micro),
              Text('64% Spent', style: context.text.headlineSmall),
            ],
          ),
        ),
        const Icon(
          Icons.account_balance_wallet_outlined,
          color: ColorTokens.accentAmber,
        ),
      ],
    );
  }
}

