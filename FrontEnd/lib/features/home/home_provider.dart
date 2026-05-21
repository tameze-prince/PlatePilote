import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/recommendation_repository.dart';
import '../auth/providers/auth_provider.dart';

class HomeState {
  const HomeState({
    this.isLoading = true,
    this.recommendations = const [],
    this.quickMeals = const [],
    this.userName,
    this.errorMessage,
  });

  final bool isLoading;
  final List<Map<String, dynamic>> recommendations;
  final List<Map<String, dynamic>> quickMeals;
  final String? userName;
  final String? errorMessage;

  HomeState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? recommendations,
    List<Map<String, dynamic>>? quickMeals,
    String? userName,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      recommendations: recommendations ?? this.recommendations,
      quickMeals: quickMeals ?? this.quickMeals,
      userName: userName ?? this.userName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    final authState = ref.watch(authProvider);
    return HomeState(userName: authState.name);
  }

  Future<void> loadRecommendations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = ref.read(recommendationRepositoryProvider);
      final recommendations = await repo.getRecommendations(limit: 5);
      final quickMeals = await repo.getQuickMeals(maxTime: 30, limit: 3);

      state = state.copyWith(
        isLoading: false,
        recommendations: recommendations,
        quickMeals: quickMeals,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load recommendations',
      );
    }
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
