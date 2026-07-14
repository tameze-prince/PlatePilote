import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

final dataRightsRepositoryProvider = Provider<DataRightsRepository>((ref) {
  return DataRightsRepository(ref.watch(apiClientProvider));
});

class DataRightsRepository {
  const DataRightsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> exportData() async {
    final response = await _apiClient.get('/me/data-export');
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
      return body;
    }
    return <String, dynamic>{'raw': body.toString()};
  }

  Future<void> optOutAnalytics() async {
    await _apiClient.post('/me/opt-out-analytics');
  }

  Future<void> restrictProcessing() async {
    await _apiClient.post('/me/restrict-processing');
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final response = await _apiClient.delete('/me/account');
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
      return body;
    }
    return <String, dynamic>{'raw': body.toString()};
  }
}
