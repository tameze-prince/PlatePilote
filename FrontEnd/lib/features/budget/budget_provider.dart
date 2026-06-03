import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/base_repository.dart';
import '../../shared/models/budget.dart';
import 'budget_repository.dart';

/// État du budget.
class BudgetState {
  const BudgetState({
    this.currentBudget,
    this.weeklyBudget = 400,
    this.spentAmount = 0,
    this.history = const [],
    this.isLoading = false,
    this.error,
    this.useDemoFallback = false,
  });

  /// Budget actuel (depuis l'API).
  final Budget? currentBudget;
  /// Montant du budget hebdomadaire.
  final double weeklyBudget;
  /// Montant dépensé.
  final double spentAmount;
  /// Historique des cycles précédents.
  final List<double> history;
  /// Vrai si le chargement est en cours.
  final bool isLoading;
  /// Message d'erreur.
  final String? error;
  /// Vrai si on utilise des données de démonstration.
  final bool useDemoFallback;

  /// Montant restant.
  double get remaining => weeklyBudget - spentAmount;
  /// Pourcentage utilisé (0.0 - 1.0).
  double get percentUsed => weeklyBudget > 0 ? (spentAmount / weeklyBudget).clamp(0, 1) : 0;

  /// Retourne une copie avec les champs modifiés.
  BudgetState copyWith({
    Budget? currentBudget,
    double? weeklyBudget,
    double? spentAmount,
    List<double>? history,
    bool? isLoading,
    String? error,
    bool? useDemoFallback,
    bool clearError = false,
  }) {
    return BudgetState(
      currentBudget: currentBudget ?? this.currentBudget,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      useDemoFallback: useDemoFallback ?? this.useDemoFallback,
    );
  }
}

/// Notifier qui gère l'état du budget.
class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    Future.microtask(() => _loadBudget());
    return const BudgetState(isLoading: true, useDemoFallback: true);
  }

  /// Charge le budget depuis l'API.
  Future<void> _loadBudget() async {
    try {
      final repo = ref.read(budgetRepositoryProvider);
      final page = await repo.listBudgets(size: 1);
      if (page.content.isNotEmpty) {
        final budget = page.content.first;
        state = BudgetState(
          currentBudget: budget,
          weeklyBudget: budget.amount ?? 400,
        );
      }
    } on ApiException {
      state = const BudgetState(useDemoFallback: true);
    }
  }

  /// Crée un nouveau budget via l'API.
  Future<void> createBudget({required double amount, String period = 'WEEKLY'}) async {
    final now = DateTime.now();
    final startDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      final repo = ref.read(budgetRepositoryProvider);
      final budget = await repo.createBudget(
        amount: amount,
        period: period,
        startDate: startDate,
      );
      state = BudgetState(
        currentBudget: budget,
        weeklyBudget: budget.amount ?? amount,
      );
    } on ApiException catch (e) {
      state = state.copyWith(weeklyBudget: amount, error: e.message);
    }
  }

  /// Augmente le budget d'une valeur donnée.
  void increaseBudget(double value) {
    state = state.copyWith(
      weeklyBudget: state.weeklyBudget + value,
    );
  }

  /// Remplace le budget par une nouvelle valeur.
  void replaceBudget(double value) {
    state = state.copyWith(
      weeklyBudget: value,
      spentAmount: 0,
    );
  }

  /// Réinitialise le cycle et archive les dépenses dans l'historique.
  void resetCycle() {
    state = state.copyWith(
      history: [...state.history, state.spentAmount],
      spentAmount: 0,
    );
  }

  /// Recharge le budget depuis l'API.
  Future<void> refresh() => _loadBudget();
}

/// Provider Riverpod pour le budget.
final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);
