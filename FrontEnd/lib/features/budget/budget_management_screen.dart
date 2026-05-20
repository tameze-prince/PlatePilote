import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/budget_meter.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'budget_provider.dart';

class BudgetManagementScreen extends ConsumerWidget {
  const BudgetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final notifier = ref.read(budgetProvider.notifier);

    return PlateScaffold(
      title: 'Budget',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current weekly budget', style: context.text.bodyMedium),
                Text(
                  '\$${budget.weeklyBudget.toStringAsFixed(0)}',
                  style: context.text.displaySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                BudgetMeter(
                  progress: budget.percentUsed.clamp(0, 1),
                  caption:
                      '\$${budget.remaining.toStringAsFixed(0)} remaining - \$${budget.spentAmount.toStringAsFixed(0)} spent',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: '+ \$25',
                  icon: Icons.add,
                  onPressed: () => notifier.increaseBudget(25),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: SecondaryButton(
                  label: 'Replace',
                  icon: Icons.edit,
                  onPressed: () => notifier.replaceBudget(400),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          PrimaryButton(
            label: 'Reset budget cycle',
            icon: Icons.restart_alt,
            onPressed: notifier.resetCycle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Historical trends', style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final value in budget.history)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        height: (value / 400 * 130).clamp(24, 130),
                        decoration: BoxDecoration(
                          color: ColorTokens.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
