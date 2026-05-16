import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';

class BudgetState {
  const BudgetState({
    required this.weeklyBudget,
    required this.spentAmount,
    required this.history,
  });

  final double weeklyBudget;
  final double spentAmount;
  final List<double> history;

  double get remaining => weeklyBudget - spentAmount;
  double get percentUsed => weeklyBudget == 0 ? 0 : spentAmount / weeklyBudget;

  BudgetState copyWith({
    double? weeklyBudget,
    double? spentAmount,
    List<double>? history,
  }) {
    return BudgetState(
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      history: history ?? this.history,
    );
  }
}

class BudgetNotifier extends Notifier<BudgetState> {
  static const _budgetKey = 'budget.weeklyBudget';
  static const _spentKey = 'budget.spentAmount';
  static const _historyKey = 'budget.history';

  @override
  BudgetState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return BudgetState(
      weeklyBudget: prefs.getDouble(_budgetKey) ?? 400,
      spentAmount: prefs.getDouble(_spentKey) ?? 144,
      history: (prefs.getStringList(_historyKey) ?? [])
          .map((e) => double.parse(e))
          .toList(),
    );
  }

  Future<void> setBudget(double value) async {
    state = state.copyWith(weeklyBudget: value);
    await _persist();
  }

  Future<void> increaseBudget(double value) async {
    state = state.copyWith(weeklyBudget: state.weeklyBudget + value);
    await _persist();
  }

  Future<void> replaceBudget(double value) async {
    state = state.copyWith(weeklyBudget: value, spentAmount: 0);
    await _persist();
  }

  Future<void> resetCycle() async {
    state = state.copyWith(
      spentAmount: 0,
      history: [...state.history, state.spentAmount],
    );
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_budgetKey, state.weeklyBudget);
    await prefs.setDouble(_spentKey, state.spentAmount);
    await prefs.setStringList(
      _historyKey,
      state.history.map((e) => e.toString()).toList(),
    );
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);
