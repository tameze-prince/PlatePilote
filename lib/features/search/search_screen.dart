import 'package:flutter/material.dart';

import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/meal_card.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/plate_scaffold.dart';
import '../support/filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final results = demoMeals
        .where((meal) => meal.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return PlateScaffold(
      title: 'Search',
      showBack: true,
      trailing: IconButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          builder: (_) => const FilterBottomSheet(),
        ),
        icon: const Icon(Icons.tune),
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            autofocus: true,
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              hintText: 'Search meals, pantry items, recipes...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Results', style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          for (final meal in results)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: MealCard(meal: meal),
            ),
        ],
      ),
    );
  }
}
