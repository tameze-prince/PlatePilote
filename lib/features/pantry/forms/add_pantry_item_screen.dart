import 'package:flutter/material.dart';

import '../../../shared/widgets/form_page.dart';
import '../../../shared/widgets/plate_scaffold.dart';

class AddPantryItemScreen extends StatelessWidget {
  const AddPantryItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlateScaffold(
      title: 'Add Pantry Item',
      showBack: true,
      child: FormPage(
        submitLabel: 'Add pantry item',
        children: [
          TextField(decoration: InputDecoration(labelText: 'Ingredient name')),
          _CategoryDropdown(),
          TextField(decoration: InputDecoration(labelText: 'Quantity')),
          TextField(decoration: InputDecoration(labelText: 'Unit')),
          TextField(decoration: InputDecoration(labelText: 'Expiration date')),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Notes'),
          ),
        ],
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: 'Vegetables',
      items:
          const [
                'Vegetables',
                'Fruits',
                'Dairy',
                'Meat',
                'Grains',
                'Spices',
                'Frozen',
                'Pantry Staples',
              ]
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
      onChanged: (_) {},
      decoration: const InputDecoration(labelText: 'Category'),
    );
  }
}
