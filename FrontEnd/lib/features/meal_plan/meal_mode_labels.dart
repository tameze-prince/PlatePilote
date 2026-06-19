/// Centralized metadata for meal-plan generation modes.
///
/// Keeps PRD-aligned labels (`Faster`, `Healthier`, `Cheaper`, `Standard`,
/// `Family`) decoupled from backend codes
/// (`STANDARD`, `WASTELESS`, `ENDOFMONTH`, `BUSYWEEK`, `FAMILY`).
///
/// Mapping (PRD ↔ backend) defined by Bob – US-006:
///   * Faster   → BUSYWEEK   (< 30 min recipes)
///   * Healthier→ WASTELESS  (uses pantry staples, less waste)
///   * Cheaper  → ENDOFMONTH (strict budget, low cost)
///   * Standard → STANDARD   (balanced week)
///   * Family   → FAMILY     (larger portions, kid-friendly)
library;

class MealModeMeta {
  const MealModeMeta({
    required this.label,
    required this.icon,
    required this.description,
  });

  /// PRD-facing label displayed in the UI.
  final String label;

  /// Emoji icon shown inside the chip.
  final String icon;

  /// Short description below the label (tooltip / accessibility).
  final String description;
}

/// Backend mode codes are the map keys. Iterate in PRD order to keep
/// chip order predictable: Standard, Healthier, Cheaper, Faster, Family.
const Map<String, MealModeMeta> kMealModeMeta = {
  'STANDARD': MealModeMeta(
    label: 'Standard',
    icon: '⚖️',
    description: 'Balanced week',
  ),
  'WASTELESS': MealModeMeta(
    label: 'Healthier',
    icon: '🥗',
    description: 'Uses pantry staples, less waste',
  ),
  'ENDOFMONTH': MealModeMeta(
    label: 'Cheaper',
    icon: '💰',
    description: 'Strict budget, low cost',
  ),
  'BUSYWEEK': MealModeMeta(
    label: 'Faster',
    icon: '⚡',
    description: 'Under 30 minutes per meal',
  ),
  'FAMILY': MealModeMeta(
    label: 'Family',
    icon: '👨\u200d👩\u200d👧',
    description: 'Larger portions, kid-friendly',
  ),
};

/// PRD quick filters shown above the expert mode selector.
/// Each quick filter maps to the backend mode that best satisfies its intent.
const String kQuickFilterFasterBackendMode = 'BUSYWEEK';
const String kQuickFilterHealthierBackendMode = 'WASTELESS';
const String kQuickFilterCheaperBackendMode = 'ENDOFMONTH';

/// Ordered list of (label, icon, backendMode) for the quick-filter chips.
const List<({String label, String icon, String backendMode})>
    kQuickFilters = [
  (
    label: 'Faster',
    icon: '⚡',
    backendMode: kQuickFilterFasterBackendMode,
  ),
  (
    label: 'Healthier',
    icon: '🥗',
    backendMode: kQuickFilterHealthierBackendMode,
  ),
  (
    label: 'Cheaper',
    icon: '💰',
    backendMode: kQuickFilterCheaperBackendMode,
  ),
];
