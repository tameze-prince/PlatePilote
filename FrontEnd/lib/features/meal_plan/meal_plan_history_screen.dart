import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/color_tokens.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';

class MealPlanHistoryScreen extends ConsumerStatefulWidget {
  const MealPlanHistoryScreen({super.key});

  @override
  ConsumerState<MealPlanHistoryScreen> createState() =>
      _MealPlanHistoryScreenState();
}

class _MealPlanHistoryScreenState
    extends ConsumerState<MealPlanHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _history = [
        {
          'week': 'May 12-18, 2026',
          'meals': 21,
          'avgCalories': 450,
          'cost': 142.50,
          'saved': true,
        },
        {
          'week': 'May 5-11, 2026',
          'meals': 21,
          'avgCalories': 480,
          'cost': 156.00,
          'saved': true,
        },
        {
          'week': 'Apr 28-May 4, 2026',
          'meals': 18,
          'avgCalories': 420,
          'cost': 128.75,
          'saved': false,
        },
        {
          'week': 'Apr 21-27, 2026',
          'meals': 21,
          'avgCalories': 465,
          'cost': 138.25,
          'saved': true,
        },
      ];
      _isLoading = false;
    });
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
                    final week = _history[index];
                    return _buildHistoryCard(week);
                  },
                ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> week) {
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
                    color: week['saved'] == true
                        ? ColorTokens.primaryGreen.withOpacity(0.1)
                        : ColorTokens.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: Icon(
                    week['saved'] == true
                        ? Icons.check_circle
                        : Icons.pending,
                    color: week['saved'] == true
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
                        week['week'] as String,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${week['meals']} meals • ${week['avgCalories']} avg cal',
                        style: context.text.bodySmall?.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${(week['cost'] as double).toStringAsFixed(2)}',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
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
                    onPressed: () {},
                    icon: const Icon(Icons.refresh_outlined, size: 16),
                    label: const Text('Reuse'),
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
