import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  BudgetState build() {
    return const BudgetState(
      weeklyBudget: 400,
      spentAmount: 144,
      history: [310, 368, 340, 388, 356],
    );
  }

  void setBudget(double value) {
    state = state.copyWith(weeklyBudget: value);
  }

  void increaseBudget(double value) {
    state = state.copyWith(weeklyBudget: state.weeklyBudget + value);
  }

  void replaceBudget(double value) {
    state = state.copyWith(weeklyBudget: value, spentAmount: 0);
  }

  void resetCycle() {
    state = state.copyWith(
      spentAmount: 0,
      history: [...state.history, state.spentAmount],
    );
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);
