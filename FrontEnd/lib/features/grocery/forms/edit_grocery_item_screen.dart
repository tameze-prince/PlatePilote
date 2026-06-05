import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/color_tokens.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../shared/models/demo_data.dart';

/// Écran d'édition d'un article de la liste de courses.
/// Permet de modifier le nom, la quantité, le prix et la catégorie.
class EditGroceryItemScreen extends ConsumerStatefulWidget {
  /// Article à modifier (null pour un ajout).
  final GroceryItem? item;

  const EditGroceryItemScreen({super.key, this.item});

  @override
  ConsumerState<EditGroceryItemScreen> createState() =>
      _EditGroceryItemScreenState();
}

class _EditGroceryItemScreenState extends ConsumerState<EditGroceryItemScreen> {
  /// Clé globale pour la validation du formulaire.
  final _formKey = GlobalKey<FormState>();

  /// Contrôleur pour le nom de l'article.
  late TextEditingController _nameController;

  /// Contrôleur pour la quantité.
  late TextEditingController _quantityController;

  /// Contrôleur pour le prix.
  late TextEditingController _priceController;

  /// Catégorie sélectionnée.
  late String _selectedCategory;

  /// Indique si l'article est coché (acheté).
  late bool _isChecked;

  /// Liste des catégories disponibles.
  final List<String> _categories = [
    'Produce',
    'Dairy & Eggs',
    'Protein',
    'Pantry Staples',
    'Beverages',
    'Snacks',
    'Frozen',
    'Bakery',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity ?? '',
    );
    _priceController = TextEditingController(
      text: widget.item?.price.replaceAll(r'$', '') ?? '',
    );
    _selectedCategory = widget.item?.category ?? _categories.first;
    _isChecked = widget.item?.checked ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Sauvegarde les modifications et retourne à l'écran précédent.
  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (context.mounted) {
      context.pop();
    }
  }

  /// Supprime l'article après confirmation et retourne à l'écran précédent.
  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text(
          'Are you sure you want to remove this item from your grocery list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: ColorTokens.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add to Grocery List'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: ColorTokens.error,
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Details',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'e.g., Organic Apples',
                        prefixIcon: const Icon(Icons.shopping_basket_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadius.input,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              hintText: 'e.g., 5, 2 bags',
                              prefixIcon: const Icon(Icons.numbers),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.input,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Price',
                              hintText: '0.00',
                              prefixIcon: const Icon(Icons.attach_money),
                              prefixText: '\$',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.input,
                                ),
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid price';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                          selectedColor: ColorTokens.primaryGreen.withValues(alpha: 
                            0.2,
                          ),
                          checkmarkColor: ColorTokens.primaryGreen,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? ColorTokens.primaryGreen
                                : ColorTokens.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(
                      _isChecked
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: _isChecked
                          ? ColorTokens.primaryGreen
                          : ColorTokens.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mark as purchased',
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Item has been bought',
                            style: context.text.bodySmall?.copyWith(
                              color: ColorTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() => _isChecked = value);
                      },
                      activeThumbColor: ColorTokens.primaryGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: isEditing ? 'Save Changes' : 'Add to List',
                onPressed: _saveItem,
              ),
              if (isEditing) ...[
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: () => context.pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
