import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../premium/premium_gate.dart';
import 'budget_repository.dart';

/// Écran de suivi des économies réalisées.
class SavingsTrackerScreen extends ConsumerStatefulWidget {
  const SavingsTrackerScreen({super.key});

  @override
  ConsumerState<SavingsTrackerScreen> createState() =>
      _SavingsTrackerScreenState();
}

class _SavingsTrackerScreenState extends ConsumerState<SavingsTrackerScreen> {
  /// Montant total économisé.
  double _totalSaved = 0;
  /// Objectif mensuel.
  double _monthlyGoal = 0;
  /// Historique mensuel des économies.
  List<Map<String, dynamic>> _monthlyHistory = [];
  /// Sources d'économies.
  List<Map<String, dynamic>> _savingsSources = [];
  /// Vrai si le chargement est en cours.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavings());
  }

  /// Charge les données d'économies depuis l'API.
  Future<void> _loadSavings() async {
    try {
      final repo = ref.read(budgetRepositoryProvider);
      final savings = await repo.getSavings();

      setState(() {
        _totalSaved = (savings['totalSaved'] as num?)?.toDouble() ?? 0;
        _monthlyGoal = (savings['monthlyGoal'] as num?)?.toDouble() ?? 0;

        final historyRaw = savings['monthlyHistory'] as List?;
        if (historyRaw != null) {
          _monthlyHistory = historyRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }

        final sourcesRaw = savings['savingsSources'] as List?;
        if (sourcesRaw != null) {
          _savingsSources = sourcesRaw.map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            if (!m.containsKey('icon')) m['icon'] = Icons.savings;
            if (!m.containsKey('color')) m['color'] = AppColors.primaryLight;
            return m;
          }).toList();
        }

        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Savings Tracker')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Tracker'),
      ),
      body: PremiumGate(
        message: 'Suivi des économies',
        child: SingleChildScrollView(
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
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: const Icon(
                          Icons.savings,
                          color: AppColors.primaryLight,
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
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '\$${_totalSaved.toStringAsFixed(2)}',
                              style: context.text.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryLight,
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
                                color: AppColors.onSurfaceVariant,
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
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${((_totalSaved / _monthlyGoal) * 100).toInt()}%',
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryLight,
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
                      backgroundColor: AppColors.surfaceContainerLow,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryLight,
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
                        barColor: AppColors.primaryLight,
                        targetColor: AppColors.secondary,
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
      ),
    );
  }

  /// Construit une ligne de source d'économie.
  Widget _buildSourceRow(Map<String, dynamic> source) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: (source['color'] as Color).withValues(alpha: 0.1),
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
                    backgroundColor: AppColors.surfaceContainerLow,
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

  /// Construit une carte de succès (achievement).
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
                ? AppColors.secondary.withValues(alpha: 0.1)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            color: unlocked
                ? AppColors.secondary
                : AppColors.onSurfaceVariant,
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
                      ? AppColors.onBackground
                      : AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                description,
                style: context.text.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Icon(
          unlocked ? Icons.check_circle : Icons.lock_outline,
          color: unlocked
              ? AppColors.primaryLight
              : AppColors.onSurfaceVariant,
          size: 20,
        ),
      ],
    );
  }
}

/// Peintre personnalisé pour le graphique d'économies mensuelles.
class _SavingsChartPainter extends CustomPainter {
  /// Données mensuelles.
  final List<Map<String, dynamic>> data;
  /// Couleur des barres d'économies.
  final Color barColor;
  /// Couleur de la ligne d'objectif.
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
        ..color = targetColor.withValues(alpha: 0.3)
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
            color: AppColors.onSurfaceVariant,
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
