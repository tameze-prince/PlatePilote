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
import '../ingredient_repository.dart';
import '../pantry_provider.dart';

/// Écran d'ajout d'article au garde-manger.
/// Permet de rechercher un ingrédient, de le sélectionner et de saisir les détails.
class AddPantryItemScreen extends ConsumerStatefulWidget {
  const AddPantryItemScreen({super.key});

  @override
  ConsumerState<AddPantryItemScreen> createState() =>
      _AddPantryItemScreenState();
}

class _AddPantryItemScreenState extends ConsumerState<AddPantryItemScreen> {
  /// Clé globale pour la validation du formulaire.
  final _formKey = GlobalKey<FormState>();

  /// Contrôleur pour la recherche.
  final _searchController = TextEditingController();

  /// Contrôleur pour le nom de l'ingrédient.
  final _nameController = TextEditingController();

  /// Contrôleur pour la quantité.
  final _quantityController = TextEditingController();

  /// Contrôleur pour l'unité.
  final _unitController = TextEditingController(text: 'unit');

  /// Contrôleur pour la date d'expiration.
  final _expirationController = TextEditingController();

  /// Catégorie sélectionnée.
  String _category = 'Vegetables';

  /// Date d'expiration choisie.
  DateTime? _expirationDate;

  /// Ingrédient sélectionné dans les résultats.
  Ingredient? _selectedIngredient;

  /// Résultats de la recherche.
  List<Ingredient> _searchResults = [];

  /// Indique si la recherche est en cours.
  bool _isSearching = false;

  /// Timer pour le debounce de la recherche.
  Timer? _debounce;

  /// Indique si les résultats doivent être affichés.
  bool _showResults = false;

  /// Indique si la sauvegarde est en cours.
  bool _saving = false;

  /// Recherches récentes.
  List<String> _recentSearches = [];

  /// Liste des catégories disponibles.
  static const _categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Grains',
    'Spices',
    'Frozen',
    'Pantry Staples',
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
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _expirationController.dispose();
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

  /// Sélectionne un ingrédient et pré-remplit le formulaire.
  void _selectIngredient(Ingredient ingredient) {
    setState(() {
      _selectedIngredient = ingredient;
      _nameController.text = ingredient.canonicalName;
      _category = ingredient.category.isNotEmpty
          ? ingredient.category[0].toUpperCase() +
                ingredient.category.substring(1)
          : 'Vegetables';
      if (_categories.contains(_category)) {
        _category = _category;
      } else {
        _category = 'Pantry Staples';
      }
      _unitController.text = ingredient.defaultUnit;
      _showResults = false;
      _searchController.clear();
    });
  }

  /// Réinitialise la sélection d'ingrédient.
  void _clearSelection() {
    setState(() {
      _selectedIngredient = null;
      _nameController.clear();
      _category = 'Vegetables';
      _unitController.text = 'unit';
    });
  }

  /// Ouvre le sélecteur de date pour choisir la date d'expiration.
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      _expirationDate = date;
      _expirationController.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  /// Soumet le formulaire et ajoute l'article au garde-manger.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(pantryProvider.notifier)
          .addItem(
            name: _nameController.text,
            category: _category,
            quantity: double.tryParse(_quantityController.text) ?? 0,
            unit: _unitController.text,
            expirationDate: _expirationDate != null
                ? '${_expirationDate!.year}-${_expirationDate!.month.toString().padLeft(2, '0')}-${_expirationDate!.day.toString().padLeft(2, '0')}'
                : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pantry item added!')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add item: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
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
                title: 'Add to Pantry',
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
                      0,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      _buildSearchSection(),
                      const SizedBox(height: AppSpacing.md),
                      _buildFormSection(),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _submit,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add_circle_outline, size: 20),
                          label: Text(_saving ? 'Adding...' : 'Add to Pantry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAccentGreen,
                            foregroundColor: PremiumTheme.isDark(context)
                                ? AppColors.darkBackground
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }

  /// Construit la section de recherche d'ingrédients.
  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.md),
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 18,
                    color: AppColors.primaryAccentGreen,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Search ingredients from our database',
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
              if (_searchController.text.isEmpty &&
                  _selectedIngredient == null &&
                  !_showResults) ...[
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
                        (cat) => _BrowseCategoryChip(
                          label: _categoryCountLabel(cat),
                          icon: _categoryIcon(cat),
                          onTap: () => _browseCategory(cat.toLowerCase()),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (_selectedIngredient != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildSelectedIngredientCard(),
              ],
              if (_showResults && _searchResults.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${_searchResults.length} results',
                  style: AppTypography.labelMedium.copyWith(
                    color: PremiumTheme.textSecondary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
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
                          trailingIcon: Icons.add_circle_outline,
                          onTap: () => _selectIngredient(_searchResults[index]),
                        ),
                        if (index != _searchResults.length - 1)
                          Divider(
                            height: 1,
                            color: PremiumTheme.border(context),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
              if (_showResults && _searchResults.isEmpty && !_isSearching) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildNoResultsCard(),
              ],
            ],
          ),
        ),
        if (_selectedIngredient == null) ...[
          const SizedBox(height: AppSpacing.md),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.md),
            elevated: true,
            backgroundColor: AppColors.info.withValues(alpha: 0.06),
            borderColor: AppColors.info.withValues(alpha: 0.15),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.info),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Search above to auto-fill ingredient info, or enter details manually below.',
                    style: AppTypography.bodySmall.copyWith(
                      color: PremiumTheme.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildBarcodeCard(),
        ],
      ],
    );
  }

  /// Construit la carte "aucun résultat".
  Widget _buildNoResultsCard() {
    final query = _searchController.text.trim();
    return GlassContainer(
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
          if (_recentSearches.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Did you mean ${_recentSearches.first}?',
              style: AppTypography.bodySmall.copyWith(
                color: PremiumTheme.textSecondary(context),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: query.isEmpty
                ? null
                : () {
                    _nameController.text = query;
                    _showResults = false;
                    _searchController.clear();
                    setState(() {});
                  },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Custom'),
          ),
        ],
      ),
    );
  }

  /// Construit la carte d'information sur le scan de code-barres (à venir).
  Widget _buildBarcodeCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryAccentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: AppColors.primaryAccentGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Barcode',
                  style: AppTypography.bodyLarge.copyWith(
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Coming soon - scan product barcodes to auto-fill',
                  style: AppTypography.bodySmall.copyWith(
                    color: PremiumTheme.textTertiary(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'Soon',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la carte récapitulative de l'ingrédient sélectionné.
  Widget _buildSelectedIngredientCard() {
    final ing = _selectedIngredient!;
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
                Icons.check_circle,
                size: 18,
                color: AppColors.primaryAccentGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                ing.canonicalName,
                style: AppTypography.titleSmall.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _clearSelection,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: PremiumTheme.textTertiary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              _nutrientChip('Cal', ing.caloriesPer100g, 'kcal'),
              _nutrientChip('Protein', ing.proteinPer100g, 'g'),
              _nutrientChip('Carbs', ing.carbohydratesPer100g, 'g'),
              _nutrientChip('Fat', ing.fatPer100g, 'g'),
              if (ing.averagePricePerKg != null)
                _nutrientChip('Price', ing.averagePricePerKg, '\$/kg'),
            ],
          ),
          if (ing.description != null && ing.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              ing.description!,
              style: AppTypography.bodySmall.copyWith(
                color: PremiumTheme.textTertiary(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (_dietaryTags(ing).isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _dietaryTags(ing)
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccentGreen.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryAccentGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Construit un chip d'information nutritionnelle.
  Widget _nutrientChip(String label, double? value, String unit) {
    if (value == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PremiumTheme.glass(context, elevated: true),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '$label ${value.toStringAsFixed(1)}$unit',
        style: AppTypography.labelSmall.copyWith(
          color: PremiumTheme.textSecondary(context),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Retourne les tags diététiques (végétalien, sans gluten, etc.).
  List<String> _dietaryTags(Ingredient ing) {
    final tags = <String>[];
    if (ing.vegan == true) tags.add('Vegan');
    if (ing.vegetarian == true) tags.add('Vegetarian');
    if (ing.glutenFree == true) tags.add('Gluten-Free');
    if (ing.halalFriendly == true) tags.add('Halal');
    if (ing.lowCarb == true) tags.add('Low Carb');
    return tags;
  }

  /// Construit le formulaire de saisie des détails de l'article.
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
                'Item Details',
                style: AppTypography.titleSmall.copyWith(
                  color: PremiumTheme.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Ingredient name *',
              hintText: 'e.g. Chicken Breast',
            ),
            validator: (v) => v?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: _categories
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
            decoration: const InputDecoration(labelText: 'Category *'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    hintText: 'e.g. 500',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit *',
                    hintText: 'g, ml, piece',
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _expirationController,
            decoration: const InputDecoration(
              labelText: 'Expiration date',
              hintText: 'Optional',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: _pickDate,
          ),
        ],
      ),
    );
  }

  /// Retourne l'icône correspondant à une catégorie.
  IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'vegetables' => Icons.eco,
      'fruits' => Icons.apple,
      'dairy' => Icons.egg_alt,
      'meat' => Icons.set_meal,
      'grains' => Icons.grain,
      'spices' => Icons.blender,
      'frozen' => Icons.ac_unit,
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
class _BrowseCategoryChip extends StatelessWidget {
  const _BrowseCategoryChip({
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

/// Extension pour simplifier l'accès aux propriétés diététiques.
extension on Ingredient {
  /// Vrai si l'ingrédient est sans gluten.
  bool get glutenFree => containsGluten == false;
}
