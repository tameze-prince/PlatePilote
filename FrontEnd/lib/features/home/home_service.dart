import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

/// Service pour les données de l'accueil.
/// Interagit avec l'API pour récupérer le tableau de bord et les économies.
class HomeService {
  HomeService(this.client);

  /// Client API pour les requêtes HTTP.
  final ApiClient client;

  /// Récupère les données du tableau de bord.
  Future<Map<String, dynamic>> fetchDashboard() async {
    try {
      final response = await client.get('/dashboard');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Récupère le montant des économies réalisées.
  Future<double> fetchSavings() async {
    try {
      final response = await client.get('/dashboard/savings');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return (data['data'] as num).toDouble();
      }
      return 0.0;
    } catch (_) {
      return 0.0;
    }
  }
}

/// Fournisseur du service d'accueil.
final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService(ref.watch(apiClientProvider));
});
