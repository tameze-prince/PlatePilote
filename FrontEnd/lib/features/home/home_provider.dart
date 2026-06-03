import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/dashboard_repository.dart';

/// État de l'écran d'accueil.
/// Contient les données du tableau de bord et l'état de chargement.
class HomeState {
  const HomeState({
    this.isLoading = true,
    this.dashboard,
    this.errorMessage,
  });

  /// Indique si le chargement est en cours.
  final bool isLoading;

  /// Données du tableau de bord.
  final DashboardData? dashboard;

  /// Message d'erreur éventuel.
  final String? errorMessage;

  /// Crée une copie avec des champs mis à jour.
  HomeState copyWith({
    bool? isLoading,
    DashboardData? dashboard,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier qui gère le chargement des données de l'accueil.
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(() => loadHome());
    return const HomeState(isLoading: true);
  }

  /// Charge les données du tableau de bord.
  Future<void> loadHome() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final dashboard = await repo.getHomeDashboard();

      state = HomeState(
        isLoading: false,
        dashboard: dashboard,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard',
      );
    }
  }
}

/// Fournisseur de l'état de l'accueil.
final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
