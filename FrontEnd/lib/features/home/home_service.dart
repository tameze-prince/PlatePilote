import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

class HomeService {
  HomeService(this.client);

  final ApiClient client;

  Future<Map<String, dynamic>> fetchDashboard() async {
    // TODO: Replace with actual API call using client
    return {};
  }

  Future<double> fetchSavings() async {
    // TODO: Replace with actual API call using client
    return 0.0;
  }
}

final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService(ref.watch(apiClientProvider));
});
