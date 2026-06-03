import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/budget.dart';

/// Repository des opérations liées au budget.
class BudgetRepository extends BaseRepository {
  BudgetRepository(super.apiClient);

  /// Liste les budgets avec pagination.
  Future<PageResponse<Budget>> listBudgets({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/budgets',
        query: {'page': page, 'size': size},
      );
      return handlePageResponse(response, Budget.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Crée un nouveau budget.
  Future<Budget> createBudget({
    required double amount,
    String currency = 'USD',
    required String period,
    required String startDate,
    String? endDate,
  }) async {
    try {
      final response = await apiClient.post('/budgets', data: {
        'amount': amount,
        'currency': currency,
        'period': period,
        'startDate': startDate,
        'endDate': endDate,
      });
      return handleResponse(response, Budget.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Supprime un budget par son ID.
  Future<void> deleteBudget(String budgetId) async {
    try {
      await apiClient.delete('/budgets/$budgetId');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère les données d'analyse du budget.
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await apiClient.get('/budgets/analytics');
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  /// Récupère les données d'économies.
  Future<Map<String, dynamic>> getSavings() async {
    try {
      final response = await apiClient.get('/budgets/savings');
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }
}

/// Provider Riverpod pour [BudgetRepository].
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(apiClientProvider));
});
