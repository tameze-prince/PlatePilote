import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/grocery/grocery_provider.dart';
import '../../../shared/models/demo_data.dart';
import '../../../shared/widgets/form_page.dart';
import '../../../shared/widgets/plate_scaffold.dart';

class AddGroceryItemScreen extends ConsumerStatefulWidget {
  const AddGroceryItemScreen({super.key});

  @override
  ConsumerState<AddGroceryItemScreen> createState() =>
      _AddGroceryItemScreenState();
}

class _AddGroceryItemScreenState extends ConsumerState<AddGroceryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _costController = TextEditingController();
  String _category = 'Produce';
  String _priority = 'Normal';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref
        .read(groceryProvider.notifier)
        .addItem(
          GroceryItem(
            name: _nameController.text,
            quantity: '${_quantityController.text} ${_unitController.text}'
                .trim(),
            price: _costController.text.isEmpty
                ? r'$0.00'
                : '\$${_costController.text}',
            category: _category,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Grocery item added!')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PlateScaffold(
      title: 'Add Grocery Item',
      showBack: true,
      child: FormPage(
        formKey: _formKey,
        submitLabel: 'Add grocery item',
        onSubmit: _submit,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Item name'),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          TextFormField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          TextFormField(
            controller: _unitController,
            decoration: const InputDecoration(labelText: 'Unit'),
          ),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: const [
              'Produce',
              'Dairy & Eggs',
              'Protein',
              'Pantry Staples',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _category = v!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            items: const [
              'Low',
              'Normal',
              'High',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _priority = v!),
            decoration: const InputDecoration(labelText: 'Priority'),
          ),
          TextFormField(
            controller: _costController,
            decoration: const InputDecoration(
              labelText: 'Estimated cost',
              prefixText: r'$ ',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
