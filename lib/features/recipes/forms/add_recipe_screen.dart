import 'package:flutter/material.dart';

import '../../../shared/widgets/form_page.dart';
import '../../../shared/widgets/plate_scaffold.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _tagsController = TextEditingController();
  final _costController = TextEditingController();
  String _difficulty = 'Easy';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _tagsController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    debugPrint('Recipe added: ${_nameController.text}, '
        'desc: ${_descriptionController.text}, '
        'prep: ${_prepTimeController.text}, '
        'cook: ${_cookTimeController.text}, '
        'difficulty: $_difficulty, '
        'servings: ${_servingsController.text}, '
        'ingredients: ${_ingredientsController.text}, '
        'instructions: ${_instructionsController.text}, '
        'tags: ${_tagsController.text}, '
        'cost: \$${_costController.text}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe saved!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PlateScaffold(
      title: 'Add Recipe',
      showBack: true,
      child: FormPage(
        formKey: _formKey,
        submitLabel: 'Save recipe',
        onSubmit: _submit,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Recipe name'),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextFormField(
            controller: _prepTimeController,
            decoration: const InputDecoration(labelText: 'Preparation time'),
          ),
          TextFormField(
            controller: _cookTimeController,
            decoration: const InputDecoration(labelText: 'Cooking time'),
          ),
          DropdownButtonFormField<String>(
            initialValue: _difficulty,
            items: const ['Easy', 'Medium', 'Advanced'].map(
              (v) => DropdownMenuItem(value: v, child: Text(v)),
            ).toList(),
            onChanged: (v) => setState(() => _difficulty = v!),
            decoration: const InputDecoration(labelText: 'Difficulty'),
          ),
          TextFormField(
            controller: _servingsController,
            decoration: const InputDecoration(labelText: 'Servings'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _ingredientsController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Ingredients'),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          TextFormField(
            controller: _instructionsController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Instructions'),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(labelText: 'Tags'),
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
