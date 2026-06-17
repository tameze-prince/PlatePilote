import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/repositories/recipe_repository.dart';
import '../../../shared/models/pantry_item.dart';
import '../../pantry/pantry_repository.dart';
import 'command_palette_result_item.dart';

/// In-app destinations surfaced in the command palette.
///
/// The `route` matches a registered [GoRoute]; `aliases` are secondary
/// keywords the user may type to surface the entry (e.g. "premium",
/// "upgrade", "subscription plan").
class CommandPalettePage {
  const CommandPalettePage({
    required this.id,
    required this.label,
    required this.route,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    this.aliases = const [],
  });

  final String id;
  final String label;
  final String route;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;
  final List<String> aliases;
}

/// Static, hand-curated list of in-app pages the palette can navigate to.
///
/// Adding a route here is a frontend-only operation — the list intentionally
/// mirrors the routes registered in `lib/app/router/routes`. When a new
/// route is added, append a new [CommandPalettePage] so it can be reached
/// via cmd-K without having to scan the bottom navigation.
const List<CommandPalettePage> _kStaticPages = <CommandPalettePage>[
  CommandPalettePage(
    id: 'home',
    label: 'Home',
    route: '/home',
    icon: Icons.home_outlined,
    iconColor: Color(0xFF22C55E),
    subtitle: 'Dashboard',
    aliases: ['dashboard', 'accueil', 'startseite'],
  ),
  CommandPalettePage(
    id: 'plan',
    label: 'Plan',
    route: '/plan',
    icon: Icons.calendar_month_outlined,
    iconColor: Color(0xFF22C55E),
    subtitle: 'Weekly meal plan',
    aliases: ['plan', 'meal plan', 'weekly'],
  ),
  CommandPalettePage(
    id: 'pantry',
    label: 'Pantry',
    route: '/pantry',
    icon: Icons.kitchen_outlined,
    iconColor: Color(0xFFF59E0B),
    subtitle: 'Inventory & expirations',
    aliases: ['pantry', 'garde-manger', 'vorratskammer', 'stock', 'inventory'],
  ),
  CommandPalettePage(
    id: 'grocery',
    label: 'Grocery',
    route: '/grocery',
    icon: Icons.shopping_cart_outlined,
    iconColor: Color(0xFFEC4899),
    subtitle: 'Shopping list',
    aliases: ['grocery', 'shopping', 'courses', 'einkaufsliste'],
  ),
  CommandPalettePage(
    id: 'search',
    label: 'Search',
    route: '/search',
    icon: Icons.search,
    iconColor: Color(0xFF38BDF8),
    subtitle: 'Recipes & more',
    aliases: ['search', 'find', 'rechercher', 'suchen'],
  ),
  CommandPalettePage(
    id: 'favorites',
    label: 'Favorites',
    route: '/favorites',
    icon: Icons.favorite_outline,
    iconColor: Color(0xFFEF4444),
    subtitle: 'Saved recipes',
    aliases: ['favorites', 'favoris', 'favoriten', 'saved'],
  ),
  CommandPalettePage(
    id: 'notifications',
    label: 'Notifications',
    route: '/notifications',
    icon: Icons.notifications_outlined,
    iconColor: Color(0xFF38BDF8),
    subtitle: 'Alerts & reminders',
    aliases: ['notifications', 'alerts', 'rappels'],
  ),
  CommandPalettePage(
    id: 'profile',
    label: 'Profile',
    route: '/profile',
    icon: Icons.person_outline,
    iconColor: Color(0xFF8B5CF6),
    subtitle: 'Account',
    aliases: ['profile', 'account', 'compte', 'profil'],
  ),
  CommandPalettePage(
    id: 'premium',
    label: 'Premium',
    route: '/premium',
    icon: Icons.workspace_premium_outlined,
    iconColor: Color(0xFF67E8F9),
    subtitle: 'Upgrade plan',
    aliases: ['premium', 'upgrade', 'subscription', 'plan'],
  ),
  CommandPalettePage(
    id: 'quick_meal',
    label: 'Quick meal',
    route: '/quick-meal',
    icon: Icons.bolt,
    iconColor: Color(0xFFF59E0B),
    subtitle: 'Fast suggestions',
    aliases: ['quick meal', 'express', 'rapide', 'schnell'],
  ),
  CommandPalettePage(
    id: 'settings',
    label: 'Settings',
    route: '/settings',
    icon: Icons.settings_outlined,
    iconColor: Color(0xFF64748B),
    subtitle: 'App preferences',
    aliases: ['settings', 'paramètres', 'einstellungen'],
  ),
];

/// One unified result row for the command palette.
class CommandPaletteResult {
  const CommandPaletteResult({
    required this.category,
    required this.label,
    required this.route,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    this.payload,
  });

  final CommandPaletteCategory category;
  final String label;
  final String route;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;

  /// Optional extra data handed to `context.go` / `context.push`.
  final Object? payload;
}

/// Snapshot of the palette state observed by the UI.
class CommandPaletteState {
  const CommandPaletteState({
    this.query = '',
    this.pages = const [],
    this.recipes = const [],
    this.pantry = const [],
    this.recipesPending = false,
    this.pantryPending = false,
    this.error,
  });

  final String query;
  final List<CommandPaletteResult> pages;
  final List<CommandPaletteResult> recipes;
  final List<CommandPaletteResult> pantry;
  final bool recipesPending;
  final bool pantryPending;
  final String? error;

  bool get isEmpty =>
      pages.isEmpty && recipes.isEmpty && pantry.isEmpty;

  CommandPaletteState copyWith({
    String? query,
    List<CommandPaletteResult>? pages,
    List<CommandPaletteResult>? recipes,
    List<CommandPaletteResult>? pantry,
    bool? recipesPending,
    bool? pantryPending,
    String? error,
    bool clearError = false,
  }) {
    return CommandPaletteState(
      query: query ?? this.query,
      pages: pages ?? this.pages,
      recipes: recipes ?? this.recipes,
      pantry: pantry ?? this.pantry,
      recipesPending: recipesPending ?? this.recipesPending,
      pantryPending: pantryPending ?? this.pantryPending,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Concatenated flatten used for keyboard navigation (arrow up/down).
  List<CommandPaletteResult> get flattened
      => <CommandPaletteResult>[...pages, ...recipes, ...pantry];
}

/// Notifier backing the command palette state.
///
/// Filtering is intentionally synchronous (cheap, runs on pages only) while
/// recipe + pantry lookups are debounced and async so the input stays
/// responsive even on flaky networks.
class CommandPaletteNotifier extends Notifier<CommandPaletteState> {
  Timer? _debounce;
  int _requestSeq = 0;

  @override
  CommandPaletteState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const CommandPaletteState();
  }

  /// Update the query string and re-trigger the async lookups.
  void setQuery(String value) {
    final q = value;
    state = state.copyWith(query: q, pages: _filterPages(q));
  }

  /// Lookup recipes & pantry items for [query] with a 200ms debounce.
  void runSearch(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _requestSeq++;
      state = state.copyWith(
        recipes: const [],
        pantry: const [],
        recipesPending: false,
        pantryPending: false,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(recipesPending: true, pantryPending: true);

    _debounce = Timer(const Duration(milliseconds: 200), () {
      _fetchRecipes(query);
      _fetchPantry(query);
    });
  }

  Future<void> _fetchRecipes(String query) async {
    final seq = ++_requestSeq;
    try {
      final response = await ref
          .read(recipeRepositoryProvider)
          .searchRecipes(query: query, size: 5);
      if (seq != _requestSeq) return; // a newer request superseded us
      final results = response.content
          .map<CommandPaletteResult>(_recipeResult)
          .where((r) => r.label.isNotEmpty)
          .toList();
      state = state.copyWith(recipes: results, recipesPending: false);
    } catch (_) {
      if (seq != _requestSeq) return;
      state = state.copyWith(
        recipes: const [],
        recipesPending: false,
      );
    }
  }

  Future<void> _fetchPantry(String query) async {
    final seq = _requestSeq;
    try {
      final results = await ref
          .read(pantryRepositoryProvider)
          .search(query);
      if (seq != _requestSeq) return;
      final mapped = results
          .take(5)
          .map<CommandPaletteResult>(_pantryResult)
          .toList();
      state = state.copyWith(pantry: mapped, pantryPending: false);
    } catch (_) {
      if (seq != _requestSeq) return;
      state = state.copyWith(
        pantry: const [],
        pantryPending: false,
      );
    }
  }

  CommandPaletteResult _recipeResult(RecipeDetail r) {
    final subtitle = _recipeSubtitle(r);
    return CommandPaletteResult(
      category: CommandPaletteCategory.recipes,
      label: r.name ?? '',
      route: r.id == null ? '/search' : '/recipe/${r.id}',
      icon: Icons.restaurant_menu,
      iconColor: const Color(0xFF22C55E),
      subtitle: subtitle,
      payload: r.id,
    );
  }

  CommandPaletteResult _pantryResult(PantryItem item) {
    return CommandPaletteResult(
      category: CommandPaletteCategory.pantry,
      label: item.name,
      route: '/pantry',
      icon: Icons.kitchen_outlined,
      iconColor: const Color(0xFF8B5CF6),
      subtitle: item.category ?? 'Pantry',
      payload: item.id,
    );
  }

  /// Filter static pages against the query (case-insensitive contains,
  /// also scans [CommandPalettePage.aliases]). Empty query returns the
  /// top 6 pages as quick destinations.
  List<CommandPaletteResult> _filterPages(String query) {
    final q = query.trim().toLowerCase();
    Iterable<CommandPalettePage> candidate = _kStaticPages;
    if (q.isNotEmpty) {
      candidate = candidate.where((page) {
        if (page.label.toLowerCase().contains(q)) return true;
        if (page.route.toLowerCase().contains(q)) return true;
        if (page.subtitle?.toLowerCase().contains(q) ?? false) return true;
        return page.aliases.any((a) => a.toLowerCase().contains(q));
      });
    } else {
      candidate = candidate.take(6);
    }
    return candidate
        .map(
          (page) => CommandPaletteResult(
            category: CommandPaletteCategory.pages,
            label: page.label,
            route: page.route,
            icon: page.icon,
            iconColor: page.iconColor,
            subtitle: page.subtitle,
          ),
        )
        .toList(growable: false);
  }

  static String _recipeSubtitle(RecipeDetail r) {
    final total = r.totalTimeMinutes;
    final mealType = r.mealType;
    final parts = <String>[];
    if (total != null) parts.add('$total min');
    if (mealType != null && mealType.isNotEmpty) parts.add(mealType);
    return parts.join(' • ');
  }
}

/// Riverpod provider exposing the command palette state.
final commandPaletteProvider =
    NotifierProvider<CommandPaletteNotifier, CommandPaletteState>(
  CommandPaletteNotifier.new,
);
