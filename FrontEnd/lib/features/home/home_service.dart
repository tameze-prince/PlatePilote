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
    // TODO: Replace with actual API call using client
    return {};
  }

  /// Récupère le montant des économies réalisées.
  Future<double> fetchSavings() async {
    // TODO: Replace with actual API call using client
    return 0.0;
  }
}

/// Fournisseur du service d'accueil.
final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService(ref.watch(apiClientProvider));
});
