import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/dashboard_repository.dart';

class HomeState {
  const HomeState({
    this.isLoading = true,
    this.dashboard,
    this.errorMessage,
  });

  final bool isLoading;
  final DashboardData? dashboard;
  final String? errorMessage;

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

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(() => loadHome());
    return const HomeState(isLoading: true);
  }

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

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
