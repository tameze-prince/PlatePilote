import 'package:flutter/material.dart';

import '../../../shared/widgets/form_page.dart';
import '../../../shared/widgets/plate_scaffold.dart';

class AddGroceryItemScreen extends StatelessWidget {
  const AddGroceryItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlateScaffold(
      title: 'Add Grocery Item',
      showBack: true,
      child: FormPage(
        submitLabel: 'Add grocery item',
        children: [
          TextField(decoration: InputDecoration(labelText: 'Item name')),
          TextField(decoration: InputDecoration(labelText: 'Quantity')),
          TextField(decoration: InputDecoration(labelText: 'Unit')),
          _CategoryDropdown(),
          _PriorityDropdown(),
          TextField(decoration: InputDecoration(labelText: 'Estimated cost')),
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
      initialValue: 'Produce',
      items: const ['Produce', 'Dairy & Eggs', 'Protein', 'Pantry Staples']
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (_) {},
      decoration: const InputDecoration(labelText: 'Category'),
    );
  }
}

class _PriorityDropdown extends StatelessWidget {
  const _PriorityDropdown();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: 'Normal',
      items: const ['Low', 'Normal', 'High']
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (_) {},
      decoration: const InputDecoration(labelText: 'Priority'),
    );
  }
}
