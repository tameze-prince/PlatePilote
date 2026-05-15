import 'package:flutter/material.dart';

import '../../../shared/widgets/form_page.dart';
import '../../../shared/widgets/plate_scaffold.dart';

class AddRecipeScreen extends StatelessWidget {
  const AddRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlateScaffold(
      title: 'Add Recipe',
      showBack: true,
      child: FormPage(
        submitLabel: 'Save recipe',
        children: [
          TextField(decoration: InputDecoration(labelText: 'Recipe name')),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          TextField(decoration: InputDecoration(labelText: 'Preparation time')),
          TextField(decoration: InputDecoration(labelText: 'Cooking time')),
          _DifficultyDropdown(),
          TextField(decoration: InputDecoration(labelText: 'Servings')),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Ingredients'),
          ),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(labelText: 'Instructions'),
          ),
          TextField(decoration: InputDecoration(labelText: 'Tags')),
          TextField(decoration: InputDecoration(labelText: 'Estimated cost')),
        ],
      ),
    );
  }
}

class _DifficultyDropdown extends StatelessWidget {
  const _DifficultyDropdown();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: 'Easy',
      items: const ['Easy', 'Medium', 'Advanced']
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (_) {},
      decoration: const InputDecoration(labelText: 'Difficulty'),
    );
  }
}
