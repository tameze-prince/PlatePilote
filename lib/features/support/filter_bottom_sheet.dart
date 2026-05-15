import 'package:flutter/material.dart';

import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: context.text.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: const [
                FilterChip(
                  label: Text('Under 20 min'),
                  selected: true,
                  onSelected: null,
                ),
                FilterChip(
                  label: Text('Budget friendly'),
                  selected: true,
                  onSelected: null,
                ),
                FilterChip(
                  label: Text('Uses pantry'),
                  selected: false,
                  onSelected: null,
                ),
                FilterChip(
                  label: Text('High protein'),
                  selected: false,
                  onSelected: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
