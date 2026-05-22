import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/grocery/grocery_provider.dart';
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
  final _unitController = TextEditingController(text: 'unit');
  final _costController = TextEditingController();
  String _category = 'Produce';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(groceryProvider.notifier).addItem(
      name: _nameController.text,
      category: _category,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      unit: _unitController.text,
      estimatedPrice: double.tryParse(_costController.text),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grocery item added!')),
    );
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
