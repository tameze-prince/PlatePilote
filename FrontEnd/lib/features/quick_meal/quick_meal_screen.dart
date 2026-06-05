import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/repositories/recommendation_repository.dart';
import '../../core/widgets/empty_state.dart';
import '../../shared/widgets/plate_scaffold.dart';

/// Écran de sélection de repas rapides.
class QuickMealScreen extends ConsumerStatefulWidget {
  const QuickMealScreen({super.key});

  @override
  ConsumerState<QuickMealScreen> createState() => _QuickMealScreenState();
}

class _QuickMealScreenState extends ConsumerState<QuickMealScreen> {
  /// Liste des repas rapides disponibles.
  List<Map<String, dynamic>> _meals = [];
  /// Indique si le chargement est en cours.
  bool _isLoading = true;
  /// Temps maximum en minutes pour les repas.
  int _maxTime = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMeals());
  }

  /// Charge les repas rapides depuis le repository.
  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(recommendationRepositoryProvider);
      final meals = await repo.getQuickMeals(maxTime: _maxTime, limit: 10);
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _meals = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlateScaffold(
      title: 'Quick Meals',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Text('Max time: '),
                const SizedBox(width: AppSpacing.sm),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 15, label: Text('15m')),
                    ButtonSegment(value: 30, label: Text('30m')),
                    ButtonSegment(value: 45, label: Text('45m')),
                  ],
                  selected: {_maxTime},
                  onSelectionChanged: (v) {
                    setState(() => _maxTime = v.first);
                    _loadMeals();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _meals.isEmpty
                    ? const EmptyState(
                        icon: Icons.restaurant,
                        title: 'No quick meals found',
                        message: 'Try increasing the time limit.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _meals.length,
                        itemBuilder: (context, index) {
                          final meal = _meals[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              leading: meal['imageUrl'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        meal['imageUrl'] as String,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(Icons.restaurant, size: 40),
                                      ),
                                    )
                                  : const Icon(Icons.restaurant, size: 40),
                              title: Text(meal['name'] as String? ?? 'Quick Meal'),
                              subtitle: Text(
                                '${meal['totalTimeMinutes'] ?? '?'} min · ${meal['cuisineType'] ?? ''}',
                              ),
                              trailing: meal['estimatedCost'] != null
                                  ? Text('\$${(meal['estimatedCost'] as num).toStringAsFixed(0)}')
                                  : null,
                              onTap: () {
                                final id = meal['id']?.toString();
                                if (id != null) {
                                  context.push('/recipe/$id');
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
