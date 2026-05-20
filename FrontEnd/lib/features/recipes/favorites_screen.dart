import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/color_tokens.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../shared/models/demo_data.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<Meal> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _favorites = [
        const Meal(
          day: '',
          type: 'Dinner',
          title: 'Mediterranean Quinoa Bowl',
          minutes: 15,
          kcal: 450,
          icon: Icons.rice_bowl,
          tint: Color(0xFF22C55E),
        ),
        const Meal(
          day: '',
          type: 'Dinner',
          title: 'Grilled Salmon & Asparagus',
          minutes: 25,
          kcal: 520,
          icon: Icons.set_meal,
          tint: Color(0xFF3B82F6),
        ),
        const Meal(
          day: '',
          type: 'Dinner',
          title: 'Zucchini Pesto Penne',
          minutes: 20,
          kcal: 380,
          icon: Icons.dinner_dining,
          tint: Color(0xFFF59E0B),
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Meal meal) async {
    setState(() => _favorites.remove(meal));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? EmptyState(
                  icon: Icons.favorite_border,
                  title: 'No favorites yet',
                  message: 'Save recipes you love to find them quickly',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final meal = _favorites[index];
                    return _buildFavoriteCard(meal);
                  },
                ),
    );
  }

  Widget _buildFavoriteCard(Meal meal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: meal.tint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Icon(meal.icon, color: meal.tint, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.title,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${meal.minutes} min • ${meal.kcal} kcal • ${meal.type}',
                    style: context.text.bodySmall?.copyWith(
                      color: ColorTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: ColorTokens.error),
              onPressed: () => _removeFavorite(meal),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
