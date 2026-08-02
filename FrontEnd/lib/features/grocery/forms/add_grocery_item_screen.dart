import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/premium_components.dart';
import '../../../core/utils/search_utils.dart';
import '../../../core/widgets/search_result_item.dart';
import '../../../shared/models/ingredient.dart';
import '../../pantry/ingredient_repository.dart';
import '../grocery_provider.dart';

/// Écran d'ajout d'articles à la liste de courses.
/// Permet de rechercher des ingrédients, d'en sélectionner plusieurs et de les ajouter.
class AddGroceryItemScreen extends ConsumerStatefulWidget {
  const AddGroceryItemScreen({super.key});

  @override
  ConsumerState<AddGroceryItemScreen> createState() =>
      _AddGroceryItemScreenState();
}

class _AddGroceryItemScreenState extends ConsumerState<AddGroceryItemScreen> {
  /// Clé globale pour la validation du formulaire.
  final _formKey = GlobalKey<FormState>();

  /// Contrôleur pour la recherche.
  final _searchController = TextEditingController();

  /// Contrôleur pour la saisie manuelle du nom.
  final _manualNameController = TextEditingController();

  /// Contrôleur pour la quantité.
  final _manualQuantityController = TextEditingController(text: '1');

  /// Contrôleur pour l'unité.
  final _unitController = TextEditingController(text: 'unit');

  /// Contrôleur pour les notes.
  final _notesController = TextEditingController();

  /// Catégorie sélectionnée.
  String _category = 'Produce';

  /// Indique si l'ajout est en cours.
  bool _adding = false;

  /// Timer pour le debounce de la recherche.
  Timer? _debounce;

  /// Indique si la recherche est en cours.
  bool _isSearching = false;

  /// Indique si les résultats doivent être affichés.
  bool _showResults = false;

  /// Résultats de la recherche.
  List<Ingredient> _searchResults = [];

  /// Recherches récentes de l'utilisateur.
  List<String> _recentSearches = [];

  /// Ingrédients sélectionnés pour l'ajout.
  final Set<Ingredient> _selectedIngredients = {};

  /// Liste des catégories disponibles.
  static const _categories = [
    'Produce',
    'Dairy & Eggs',
    'Protein',
    'Pantry Staples',
    'Frozen',
    'Bakery',
    'Spices',
    'Beverages',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _manualNameController.dispose();
    _manualQuantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Déclenche la recherche après un délai (debounce).
  void _onSearchChanged() {
    _debounce?.cancel();
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  /// Effectue la recherche d'ingrédients via le dépôt.
  Future<void> _search(String query) async {
    setState(() => _isSearching = true);
    try {
      final repo = ref.read(ingredientRepositoryProvider);
      final results = await repo.search(query);
      if (!mounted) return;
      setState(() {
        _searchResults = SearchUtils.sortIngredients(results, query);
        _recentSearches = [
          query,
          ..._recentSearches.where((item) => item != query),
        ].take(5).toList();
        _showResults = true;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _showResults = true;
        _isSearching = false;
      });
    }
  }

  /// Parcourt les ingrédients d'une catégorie donnée.
  Future<void> _browseCategory(String category) async {
    setState(() {
      _isSearching = true;
      _showResults = true;
    });
    try {
      final repo = ref.read(ingredientRepositoryProvider);
      final results = await repo.getByCategory(category);
      if (!mounted) return;
      setState(() {
        _searchResults = SearchUtils.sortIngredients(results, '');
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
    }
  }

  /// Ajoute ou retire un ingrédient de la sélection.
  void _toggleIngredient(Ingredient ing) {
    setState(() {
      if (_selectedIngredients.contains(ing)) {
        _selectedIngredients.remove(ing);
      } else {
        _selectedIngredients.add(ing);
      }
    });
  }

  /// Sélectionne tous les résultats de la recherche.
  void _selectAllResults() {
    setState(() => _selectedIngredients.addAll(_searchResults));
  }

  /// Soumet le formulaire et ajoute les articles à la liste de courses.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _adding = true);
    try {
      final notifier = ref.read(groceryProvider.notifier);

      final qty = double.tryParse(_manualQuantityController.text) ?? 1;
      final unit = _unitController.text.trim().isEmpty
          ? 'unit'
          : _unitController.text.trim();
      final notes = _notesController.text.isNotEmpty
          ? _notesController.text.trim()
          : null;

      if (_selectedIngredients.isNotEmpty) {
        for (final ing in _selectedIngredients) {
          await notifier.addItem(
            name: ing.canonicalName,
            category: _category,
            quantity: qty,
            unit: unit,
            notes: notes,
          );
        }
      } else if (_manualNameController.text.trim().isNotEmpty) {
        await notifier.addItem(
          name: _manualNameController.text.trim(),
          category: _category,
          quantity: qty,
          unit: unit,
          notes: notes,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select ingredients or enter a name')),
          );
        }
        setState(() => _adding = false);
        return;
      }

      if (!mounted) return;
      final count = _selectedIngredients.isNotEmpty
          ? _selectedIngredients.length
          : 1;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$count item(s) added!')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add: $e')));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.background(context),
      body: PremiumBackground(
        safeArea: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FloatingHeader(
                title: 'Add Grocery Items',
                subtitle: _selectedIngredients.isNotEmpty
                    ? '${_selectedIngredients.length} selected'
                    : null,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccentGreen,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: PremiumTheme.glow(context),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: PremiumTheme.isDark(context)
                          ? AppColors.darkBackground
                          : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    children: [
                      _buildSearchSection(),
                      const SizedBox(height: AppSpacing.md),
                      _buildSelectedSection(),
                      const SizedBox(height: AppSpacing.md),
                      _buildFormSection(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: _selectedIngredients.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  elevated: true,
                  backgroundColor: AppColors.primaryAccentGreen.withValues(
                    alpha: 0.12,
                  ),
                  borderColor: AppColors.primaryAccentGreen.withValues(
                    alpha: 0.28,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_selectedIngredients.length} selected',
                          style: AppTypography.bodyMedium.copyWith(
                            color: PremiumTheme.textPrimary(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _selectedIngredients.clear()),
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: FilledButton.icon(
                          onPressed: _adding ? null : _submit,
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Construit la section de recherche d'ingrédients.
  Widget _buildSearchSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, size: 18, color: AppColors.primaryAccentGreen),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Search or browse ingredients',
                style: AppTypography.titleSmall.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Type ingredient name...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_searchController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            },
                          )
                        : null),
              filled: true,
              fillColor: PremiumTheme.glass(context, elevated: false),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: PremiumTheme.border(context)),
              ),
            ),
          ),
          if (_searchController.text.isEmpty && !_showResults) ...[
            if (_recentSearches.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Recent searches',
                style: AppTypography.labelMedium.copyWith(
                  color: PremiumTheme.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: _recentSearches
                    .map(
                      (term) => ActionChip(
                        label: Text(term),
                        avatar: const Icon(Icons.history, size: 16),
                        onPressed: () {
                          _searchController.text = term;
                          _search(term);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              'Browse by category',
              style: AppTypography.labelMedium.copyWith(
                color: PremiumTheme.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _categories
                  .map(
                    (cat) => _BrowseChip(
                      label: _categoryCountLabel(cat),
                      icon: _categoryIcon(cat),
                      onTap: () => _browseCategory(cat.toLowerCase()),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (_showResults && _searchResults.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_searchResults.length} results',
                    style: AppTypography.labelMedium.copyWith(
                      color: PremiumTheme.textSecondary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _selectAllResults,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Select all'),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: PremiumTheme.glass(context, elevated: true),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: PremiumTheme.border(context)),
              ),
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < _searchResults.length;
                    index++
                  ) ...[
                    SearchResultItem(
                      ingredient: _searchResults[index],
                      query: _searchController.text,
                      icon: _categoryIcon(_searchResults[index].category),
                      selected: _selectedIngredients.contains(
                        _searchResults[index],
                      ),
                      onTap: () => _toggleIngredient(_searchResults[index]),
                    ),
                    if (index != _searchResults.length - 1)
                      Divider(height: 1, color: PremiumTheme.border(context)),
                  ],
                ],
              ),
            ),
          ],
          if (_showResults && _searchResults.isEmpty && !_isSearching)
            _buildNoResults(),
        ],
      ),
    );
  }

  /// Construit l'état "aucun résultat" pour la recherche.
  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No ingredients found',
              style: AppTypography.bodyMedium.copyWith(
                color: PremiumTheme.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add "${_searchController.text.trim()}" as a custom grocery item.',
              style: AppTypography.bodySmall.copyWith(
                color: PremiumTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              onPressed: () {
                _manualNameController.text = _searchController.text.trim();
                _searchController.clear();
                setState(() => _showResults = false);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Custom'),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la section des ingrédients sélectionnés.
  Widget _buildSelectedSection() {
    if (_selectedIngredients.isEmpty) return const SizedBox.shrink();
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      backgroundColor: AppColors.primaryAccentGreen.withValues(alpha: 0.08),
      borderColor: AppColors.primaryAccentGreen.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist,
                size: 18,
                color: AppColors.primaryAccentGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Selected Ingredients',
                style: AppTypography.titleSmall.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _selectedIngredients.clear()),
                child: Text(
                  'Clear all',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryAccentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _selectedIngredients
                .map(
                  (ing) => Chip(
                    label: Text(
                      ing.canonicalName,
                      style: const TextStyle(fontSize: 13),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _toggleIngredient(ing),
                    backgroundColor: AppColors.primaryAccentGreen.withValues(
                      alpha: 0.12,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Construit le formulaire de saisie manuelle.
  Widget _buildFormSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note,
                size: 18,
                color: AppColors.primaryAccentGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _selectedIngredients.isNotEmpty
                    ? 'Settings for Selected Items'
                    : 'Manual Entry',
                style: AppTypography.titleSmall.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (_selectedIngredients.isEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _manualNameController,
              decoration: const InputDecoration(
                labelText: 'Item name *',
                hintText: 'e.g. Milk, Bread, Eggs',
                prefixIcon: Icon(Icons.shopping_basket_outlined, size: 20),
              ),
              validator: (v) {
                if (_selectedIngredients.isEmpty &&
                    (v?.trim().isEmpty ?? true)) {
                  return 'Enter a name or select ingredients above';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _category,
            items: _categories
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _manualQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'e.g. 2',
                    prefixIcon: Icon(Icons.edit_note, size: 20),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    hintText: 'g, ml, piece',
                    prefixIcon: Icon(Icons.straighten, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Optional',
              prefixIcon: Icon(Icons.notes, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le bouton de soumission.
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _adding ? null : _submit,
        icon: _adding
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_shopping_cart, size: 20),
        label: Text(
          _adding
              ? 'Adding...'
              : _selectedIngredients.isNotEmpty
              ? 'Add ${_selectedIngredients.length} item${_selectedIngredients.length > 1 ? 's' : ''}'
              : 'Add to List',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccentGreen,
          foregroundColor: PremiumTheme.isDark(context)
              ? AppColors.darkBackground
              : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  /// Retourne l'icône correspondant à une catégorie.
  IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'produce' => Icons.eco,
      'dairy & eggs' => Icons.egg_alt,
      'protein' => Icons.set_meal,
      'pantry staples' => Icons.inventory_2_outlined,
      'frozen' => Icons.ac_unit,
      'bakery' => Icons.bakery_dining,
      'spices' => Icons.blender,
      'beverages' => Icons.local_drink,
      _ => Icons.inventory_2_outlined,
    };
  }

  /// Retourne le libellé d'une catégorie avec le nombre de résultats.
  String _categoryCountLabel(String category) {
    final count = _searchResults
        .where(
          (ingredient) =>
              ingredient.category.toLowerCase() == category.toLowerCase(),
        )
        .length;
    return count > 0 ? '$category ($count)' : category;
  }
}

/// Chip de navigation pour parcourir une catégorie d'ingrédients.
class _BrowseChip extends StatelessWidget {
  const _BrowseChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  /// Texte du chip.
  final String label;

  /// Icône du chip.
  final IconData icon;

  /// Callback au clic.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          color: AppColors.primaryAccentGreen.withValues(alpha: 0.12),
          border: Border.all(
            color: AppColors.primaryAccentGreen.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primaryAccentGreen),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryAccentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
