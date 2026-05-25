import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/repositories/base_repository.dart';
import '../../shared/models/budget.dart';

class BudgetRepository extends BaseRepository {
  BudgetRepository(super.apiClient);

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
        if (endDate != null) 'endDate': endDate,
      });
      return handleResponse(response, Budget.fromJson);
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      await apiClient.delete('/budgets/$budgetId');
    } on DioException catch (e) {
      throw ApiException(extractMessage(e), e.response?.statusCode);
    }
  }

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

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(apiClientProvider));
});
