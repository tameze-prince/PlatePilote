import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/base_repository.dart';
import '../../shared/models/budget.dart';
import 'budget_repository.dart';

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

  final Budget? currentBudget;
  final double weeklyBudget;
  final double spentAmount;
  final List<double> history;
  final bool isLoading;
  final String? error;
  final bool useDemoFallback;

  double get remaining => weeklyBudget - spentAmount;
  double get percentUsed => weeklyBudget > 0 ? (spentAmount / weeklyBudget).clamp(0, 1) : 0;

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

class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    Future.microtask(() => _loadBudget());
    return const BudgetState(isLoading: true, useDemoFallback: true);
  }

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

  void increaseBudget(double value) {
    state = state.copyWith(
      weeklyBudget: state.weeklyBudget + value,
    );
  }

  void replaceBudget(double value) {
    state = state.copyWith(
      weeklyBudget: value,
      spentAmount: 0,
    );
  }

  void resetCycle() {
    state = state.copyWith(
      history: [...state.history, state.spentAmount],
      spentAmount: 0,
    );
  }

  Future<void> refresh() => _loadBudget();
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);
