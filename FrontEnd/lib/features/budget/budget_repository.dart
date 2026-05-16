import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'budget_provider.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref);
});

class BudgetRepository {
  const BudgetRepository(this._ref);

  final Ref _ref;

  BudgetState read() => _ref.read(budgetProvider);
  void increase(double amount) =>
      _ref.read(budgetProvider.notifier).increaseBudget(amount);
}
