import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/premium_components.dart';
import '../../shared/widgets/shimmer_glass_skeleton.dart';
import 'budget_provider.dart';

class BudgetManagementScreen extends ConsumerStatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  ConsumerState<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends ConsumerState<BudgetManagementScreen> {
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(budgetProvider.notifier).refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);
    final notifier = ref.read(budgetProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        child: RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              FloatingHeader(title: 'Budget', subtitle: 'Weekly spending plan'),
              const SizedBox(height: AppSpacing.md),
              if (budget.isLoading)
                ...List.generate(4, (_) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: ShimmerGlassSkeleton(width: double.infinity, height: 100),
                ))
              else ...[
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current weekly budget',
                        style: textTheme.bodyMedium?.copyWith(color: PremiumTheme.textSecondary(context))),
                      Text('\$${budget.weeklyBudget.toStringAsFixed(0)}',
                        style: textTheme.displaySmall?.copyWith(
                          color: AppColors.primaryAccentGreen, fontWeight: FontWeight.w800)),
                      const SizedBox(height: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: budget.percentUsed,
                              minHeight: 10,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation(
                                budget.percentUsed > 0.8 ? AppColors.error : AppColors.primaryAccentGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text('\$${budget.remaining.toStringAsFixed(0)} remaining - \$${budget.spentAmount.toStringAsFixed(0)} spent',
                            style: textTheme.bodySmall?.copyWith(color: PremiumTheme.textSecondary(context))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: '+ \$25', icon: Icons.add,
                        variant: GlassButtonVariant.outlined,
                        onPressed: () => notifier.increaseBudget(25),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GlassButton(
                        label: 'Replace', icon: Icons.edit,
                        variant: GlassButtonVariant.outlined,
                        onPressed: () => notifier.replaceBudget(400),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassButton(
                  label: 'Reset budget cycle', icon: Icons.restart_alt,
                  onPressed: notifier.resetCycle,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Historical trends',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.md),
                if (budget.history.isEmpty)
                  PremiumCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(
                        child: Text('No history yet. Reset a cycle to start tracking.',
                          style: textTheme.bodyMedium?.copyWith(color: PremiumTheme.textSecondary(context))),
                      ),
                    ),
                  )
                else
                  PremiumCard(
                    child: SizedBox(
                      height: 150,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: budget.history.map((value) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              height: (value / 400 * 130).clamp(24, 130),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccentGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                GlassButton(
                  label: 'Create New Budget', icon: Icons.add_chart,
                  onPressed: () => notifier.createBudget(amount: 400),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
