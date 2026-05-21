import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';

class BudgetAnalyticsScreen extends ConsumerStatefulWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  ConsumerState<BudgetAnalyticsScreen> createState() =>
      _BudgetAnalyticsScreenState();
}

class _BudgetAnalyticsScreenState extends ConsumerState<BudgetAnalyticsScreen> {
  final double _weeklyBudget = 400;
  final double _spentAmount = 256;
  final List<double> _weeklyHistory = [320, 280, 350, 290, 310, 280, 256];
  final List<String> _weekLabels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];

  double get _remaining => _weeklyBudget - _spentAmount;
  double get _percentUsed => _spentAmount / _weeklyBudget;
  double get _avgWeeklySpend =>
      _weeklyHistory.reduce((a, b) => a + b) / _weeklyHistory.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: ColorTokens.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: ColorTokens.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Budget',
                              style: context.text.bodySmall?.copyWith(
                                color: ColorTokens.textSecondary,
                              ),
                            ),
                            Text(
                              '\$${_weeklyBudget.toStringAsFixed(2)}',
                              style: context.text.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _percentUsed > 0.8
                              ? ColorTokens.error.withOpacity(0.1)
                              : ColorTokens.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '${(_percentUsed * 100).toInt()}% used',
                          style: context.text.bodySmall?.copyWith(
                            color: _percentUsed > 0.8
                                ? ColorTokens.error
                                : ColorTokens.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: _percentUsed,
                      backgroundColor: ColorTokens.surfaceContainerLow,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _percentUsed > 0.8
                            ? ColorTokens.error
                            : ColorTokens.primaryGreen,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_spentAmount.toStringAsFixed(2)} spent',
                        style: context.text.bodySmall?.copyWith(
                          color: ColorTokens.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${_remaining.toStringAsFixed(2)} remaining',
                        style: context.text.bodySmall?.copyWith(
                          color: ColorTokens.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.trending_down,
                    label: 'Avg Weekly',
                    value: '\$${_avgWeeklySpend.toStringAsFixed(0)}',
                    color: ColorTokens.accentBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.savings,
                    label: 'Saved',
                    value: '\$${(_weeklyBudget - _avgWeeklySpend).toStringAsFixed(0)}',
                    color: ColorTokens.primaryGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today,
                    label: 'Streak',
                    value: '4 weeks',
                    color: ColorTokens.accentAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Spending Trend',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 200,
                    child: CustomPaint(
                      size: const Size(double.infinity, 200),
                      painter: _BarChartPainter(
                        values: _weeklyHistory,
                        labels: _weekLabels,
                        maxValue: _weeklyBudget,
                        barColor: ColorTokens.primaryGreen,
                        budgetLine: _weeklyBudget,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending by Category',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategoryBreakdown(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: ColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final categories = [
      {'name': 'Produce', 'amount': 85.50, 'color': ColorTokens.primaryGreen},
      {'name': 'Protein', 'amount': 72.30, 'color': ColorTokens.accentBlue},
      {'name': 'Dairy', 'amount': 45.20, 'color': ColorTokens.accentAmber},
      {'name': 'Pantry', 'amount': 38.00, 'color': Color(0xFF8B5CF6)},
      {'name': 'Other', 'amount': 15.00, 'color': ColorTokens.textSecondary},
    ];

    return Column(
      children: categories.map((cat) {
        final percent = (cat['amount']! as double) / _spentAmount;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: cat['color'] as Color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  cat['name']! as String,
                  style: context.text.bodyMedium,
                ),
              ),
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: ColorTokens.surfaceContainerLow,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      cat['color'] as Color,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 60,
                child: Text(
                  '\$${(cat['amount']! as double).toStringAsFixed(0)}',
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final Color barColor;
  final double budgetLine;

  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.barColor,
    required this.budgetLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / values.length * 0.6;
    final barSpacing = size.width / values.length * 0.4;
    final maxBarHeight = size.height - 30;

    final budgetY = size.height - 20 - (budgetLine / maxValue * maxBarHeight);
    final budgetPaint = Paint()
      ..color = ColorTokens.error.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, budgetY),
      Offset(size.width, budgetY),
      budgetPaint,
    );

    for (int i = 0; i < values.length; i++) {
      final x = i * (barWidth + barSpacing) + barSpacing / 2;
      final barHeight = (values[i] / maxValue * maxBarHeight).clamp(
        0.0,
        maxBarHeight,
      );
      final y = size.height - 20 - barHeight;

      final barPaint = Paint()
        ..color = barColor
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 10,
            color: ColorTokens.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
