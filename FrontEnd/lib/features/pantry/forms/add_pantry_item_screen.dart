import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/pantry/pantry_provider.dart';
import '../../../shared/models/demo_data.dart';
import '../../../shared/widgets/form_page.dart';
import '../../../shared/widgets/plate_scaffold.dart';

class AddPantryItemScreen extends ConsumerStatefulWidget {
  const AddPantryItemScreen({super.key});

  @override
  ConsumerState<AddPantryItemScreen> createState() =>
      _AddPantryItemScreenState();
}

class _AddPantryItemScreenState extends ConsumerState<AddPantryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _expirationController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = 'Vegetables';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _expirationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      _expirationController.text = '${date.month}/${date.day}/${date.year}';
    }
  }

  Future<void> _submit() async {
    await ref
        .read(pantryProvider.notifier)
        .addItem(
          PantryItem(
            name: _nameController.text,
            quantity: '${_quantityController.text} ${_unitController.text}'
                .trim(),
            expires: _expirationController.text.isEmpty
                ? 'No expiration date'
                : 'Expires ${_expirationController.text}',
            category: _category,
            icon: Icons.inventory_2_outlined,
            urgent: false,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pantry item added!')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PlateScaffold(
      title: 'Add Pantry Item',
      showBack: true,
      child: FormPage(
        formKey: _formKey,
        submitLabel: 'Add pantry item',
        onSubmit: _submit,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Ingredient name'),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: const [
              'Vegetables',
              'Fruits',
              'Dairy',
              'Meat',
              'Grains',
              'Spices',
              'Frozen',
              'Pantry Staples',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _category = v!),
            decoration: const InputDecoration(labelText: 'Category'),
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
          TextFormField(
            controller: _expirationController,
            decoration: const InputDecoration(
              labelText: 'Expiration date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: _pickDate,
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
        ],
      ),
    );
  }
}
