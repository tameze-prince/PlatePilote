import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/color_tokens.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';

class SavingsTrackerScreen extends ConsumerStatefulWidget {
  const SavingsTrackerScreen({super.key});

  @override
  ConsumerState<SavingsTrackerScreen> createState() =>
      _SavingsTrackerScreenState();
}

class _SavingsTrackerScreenState extends ConsumerState<SavingsTrackerScreen> {
  final double _totalSaved = 142.50;
  final double _monthlyGoal = 200;
  final List<Map<String, dynamic>> _monthlyHistory = [
    {'month': 'Jan', 'saved': 85.00, 'target': 150},
    {'month': 'Feb', 'saved': 92.50, 'target': 150},
    {'month': 'Mar', 'saved': 110.00, 'target': 180},
    {'month': 'Apr', 'saved': 125.00, 'target': 180},
    {'month': 'May', 'saved': 142.50, 'target': 200},
  ];

  final List<Map<String, dynamic>> _savingsSources = [
    {
      'source': 'Pantry optimization',
      'icon': Icons.eco,
      'amount': 48.50,
      'percentage': 0.34,
      'color': ColorTokens.primaryGreen,
    },
    {
      'source': 'Budget-friendly meals',
      'icon': Icons.restaurant,
      'amount': 52.00,
      'percentage': 0.36,
      'color': ColorTokens.accentBlue,
    },
    {
      'source': 'Reduced waste',
      'icon': Icons.delete_sweep,
      'amount': 28.00,
      'percentage': 0.20,
      'color': ColorTokens.accentAmber,
    },
    {
      'source': 'Smart shopping',
      'icon': Icons.shopping_bag,
      'amount': 14.00,
      'percentage': 0.10,
      'color': Color(0xFF8B5CF6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Tracker'),
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
                          Icons.savings,
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
                              'Total Saved',
                              style: context.text.bodySmall?.copyWith(
                                color: ColorTokens.textSecondary,
                              ),
                            ),
                            Text(
                              '\$${_totalSaved.toStringAsFixed(2)}',
                              style: context.text.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorTokens.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Goal',
                              style: context.text.bodySmall?.copyWith(
                                color: ColorTokens.textSecondary,
                              ),
                            ),
                            Text(
                              '\$${_monthlyGoal.toStringAsFixed(2)}',
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress',
                              style: context.text.bodySmall?.copyWith(
                                color: ColorTokens.textSecondary,
                              ),
                            ),
                            Text(
                              '${((_totalSaved / _monthlyGoal) * 100).toInt()}%',
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorTokens.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: _totalSaved / _monthlyGoal,
                      backgroundColor: ColorTokens.surfaceContainerLow,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        ColorTokens.primaryGreen,
                      ),
                      minHeight: 8,
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
                    'Monthly Savings Trend',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 180,
                    child: CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: _SavingsChartPainter(
                        data: _monthlyHistory,
                        barColor: ColorTokens.primaryGreen,
                        targetColor: ColorTokens.accentAmber,
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
                    'Savings Sources',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ..._savingsSources.map(
                    (source) => _buildSourceRow(source),
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
                    'Achievements',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildAchievement(
                    icon: Icons.emoji_events,
                    title: 'First \$100 saved!',
                    description: 'Reached your first savings milestone',
                    unlocked: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildAchievement(
                    icon: Icons.trending_up,
                    title: 'Consistent saver',
                    description: 'Saved every month for 3 months',
                    unlocked: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildAchievement(
                    icon: Icons.star,
                    title: 'Goal crusher',
                    description: 'Exceed monthly savings goal',
                    unlocked: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceRow(Map<String, dynamic> source) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: (source['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              source['icon'] as IconData,
              color: source['color'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source['source'] as String,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: source['percentage'] as double,
                    backgroundColor: ColorTokens.surfaceContainerLow,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      source['color'] as Color,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '\$${(source['amount'] as double).toStringAsFixed(2)}',
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement({
    required IconData icon,
    required String title,
    required String description,
    required bool unlocked,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: unlocked
                ? ColorTokens.accentAmber.withOpacity(0.1)
                : ColorTokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            color: unlocked
                ? ColorTokens.accentAmber
                : ColorTokens.textSecondary,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: unlocked
                      ? ColorTokens.textPrimary
                      : ColorTokens.textSecondary,
                ),
              ),
              Text(
                description,
                style: context.text.bodySmall?.copyWith(
                  color: ColorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Icon(
          unlocked ? Icons.check_circle : Icons.lock_outline,
          color: unlocked
              ? ColorTokens.primaryGreen
              : ColorTokens.textSecondary,
          size: 20,
        ),
      ],
    );
  }
}

class _SavingsChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color barColor;
  final Color targetColor;

  _SavingsChartPainter({
    required this.data,
    required this.barColor,
    required this.targetColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / data.length * 0.5;
    final barSpacing = size.width / data.length * 0.5;
    final maxBarHeight = size.height - 40;
    final maxValue = data.fold<double>(
      0,
      (max, item) => (item['target'] as double) > max
          ? item['target'] as double
          : max,
    );

    for (int i = 0; i < data.length; i++) {
      final x = i * (barWidth + barSpacing) + barSpacing / 2;
      final savedHeight =
          ((data[i]['saved'] as double) / maxValue * maxBarHeight).clamp(
            0.0,
            maxBarHeight,
          );
      final targetHeight =
          ((data[i]['target'] as double) / maxValue * maxBarHeight).clamp(
            0.0,
            maxBarHeight,
          );

      final targetY = size.height - 30 - targetHeight;
      final targetPaint = Paint()
        ..color = targetColor.withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(x, targetY),
        Offset(x + barWidth, targetY),
        targetPaint,
      );

      final savedY = size.height - 30 - savedHeight;
      final barPaint = Paint()
        ..color = barColor
        ..style = PaintingStyle.fill;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, savedY, barWidth, savedHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i]['month'] as String,
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
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
