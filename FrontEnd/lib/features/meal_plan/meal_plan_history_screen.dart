import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../shared/models/meal_plan.dart';
import 'meal_plan_repository.dart';
import 'meal_plan_provider.dart';

/// Écran d'historique des plans de repas.
/// Permet de consulter et recharger les plans de repas passés.
class MealPlanHistoryScreen extends ConsumerStatefulWidget {
  const MealPlanHistoryScreen({super.key});

  @override
  ConsumerState<MealPlanHistoryScreen> createState() =>
      _MealPlanHistoryScreenState();
}

class _MealPlanHistoryScreenState
    extends ConsumerState<MealPlanHistoryScreen> {
  /// Liste des plans de repas historiques.
  List<MealPlan> _history = [];

  /// Indique si le chargement est en cours.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Charge l'historique des plans depuis l'API.
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      final page = await repo.listMealPlans(size: 20);
      setState(() {
        _history = page.content;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  /// Formate la plage de dates d'un plan pour l'affichage.
  String _formatDateRange(MealPlan plan) {
    final start = plan.startDate ?? '';
    final end = plan.endDate ?? '';
    if (start.length >= 10 && end.length >= 10) {
      return '${start.substring(5)}-${end.substring(5, 10)}, ${end.substring(0, 4)}';
    }
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? EmptyState(
                  icon: Icons.history,
                  title: 'No history yet',
                  message: 'Your meal plan history will appear here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final plan = _history[index];
                    return _buildHistoryCard(plan, index);
                  },
                ),
    );
  }

  /// Construit une carte d'historique pour un plan de repas.
  Widget _buildHistoryCard(MealPlan plan, int index) {
    final mealCount = plan.entries.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: plan.status == 'ACTIVE'
                        ? ColorTokens.primaryGreen.withOpacity(0.1)
                        : ColorTokens.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Icon(
                    plan.status == 'ACTIVE'
                        ? Icons.check_circle
                        : Icons.pending,
                    color: plan.status == 'ACTIVE'
                        ? ColorTokens.primaryGreen
                        : ColorTokens.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateRange(plan),
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$mealCount meals',
                        style: context.text.bodySmall?.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(mealPlanProvider.notifier).selectPlan(index);
                      context.pop();
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorTokens.primaryGreen,
                      side: const BorderSide(color: ColorTokens.primaryGreen),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(mealPlanProvider.notifier).selectPlan(index);
                      context.pop();
                    },
                    icon: const Icon(Icons.refresh_outlined, size: 16),
                    label: const Text('Load'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorTokens.accentBlue,
                      side: const BorderSide(color: ColorTokens.accentBlue),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                    ),
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
