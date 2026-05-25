import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/recipe_repository.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/models/meal_plan.dart';
import 'meal_plan_repository.dart';

class MealPlanState {
  const MealPlanState({
    this.currentPlan,
    this.meals = const [],
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    this.availablePlans = const [],
    this.selectedPlanIndex = 0,
  });

  final MealPlan? currentPlan;
  final List<Meal> meals;
  final bool isLoading;
  final bool isGenerating;
  final String? error;
  final List<MealPlan> availablePlans;
  final int selectedPlanIndex;

  bool get hasPrevPlan => selectedPlanIndex < availablePlans.length - 1;
  bool get hasNextPlan => selectedPlanIndex > 0;

  MealPlanState copyWith({
    MealPlan? currentPlan,
    List<Meal>? meals,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    List<MealPlan>? availablePlans,
    int? selectedPlanIndex,
    bool clearError = false,
  }) {
    return MealPlanState(
      currentPlan: currentPlan ?? this.currentPlan,
      meals: meals ?? this.meals,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : (error ?? this.error),
      availablePlans: availablePlans ?? this.availablePlans,
      selectedPlanIndex: selectedPlanIndex ?? this.selectedPlanIndex,
    );
  }
}

class MealPlanNotifier extends Notifier<MealPlanState> {
  @override
  MealPlanState build() {
    Future.microtask(() => _loadCurrentPlan());
    return const MealPlanState(isLoading: true);
  }

  String _nextMonday() {
    final now = DateTime.now();
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    final monday = now.add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  Future<List<Meal>> _entriesToMeals(List<MealPlanEntry> entries) async {
    const concurrency = 3;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final repo = ref.read(recipeRepositoryProvider);
    final meals = <Meal>[];
    for (var i = 0; i < entries.length; i += concurrency) {
      final batch = entries.skip(i).take(concurrency);
      final results = await Future.wait(batch.map((entry) async {
        final date = entry.mealDate != null ? DateTime.tryParse(entry.mealDate!) : null;
        final dayName = date != null ? dayNames[date.weekday - 1] : (entry.mealDate ?? '');
        String title = entry.recipeName ?? 'Unknown Recipe';
        int minutes = 25;
        int kcal = 450;
        String? imageUrl;
        IconData icon = Icons.restaurant;
        Color tint = Colors.green;
        if (entry.recipeId != null) {
          try {
            final detail = await repo.getRecipeDetail(entry.recipeId!);
            title = detail.name ?? title;
            minutes = detail.totalTimeMinutes ??
                ((detail.prepTimeMinutes ?? 0) + (detail.cookTimeMinutes ?? 0));
            imageUrl = detail.imageUrl;
          } catch (_) {}
        }
        switch (entry.mealType?.toLowerCase()) {
          case 'breakfast':
            icon = Icons.wb_sunny;
            tint = Colors.orange;
            break;
          case 'lunch':
            icon = Icons.lunch_dining;
            tint = Colors.amber;
            break;
          case 'dinner':
            icon = Icons.dinner_dining;
            tint = Colors.deepPurple;
            break;
          case 'snack':
            icon = Icons.cookie;
            tint = Colors.brown;
            break;
        }
        return Meal(
          day: dayName,
          type: entry.mealType ?? 'Meal',
          title: title,
          minutes: minutes,
          kcal: kcal,
          icon: icon,
          tint: tint,
          imageUrl: imageUrl,
          recipeId: entry.recipeId,
        );
      }));
      meals.addAll(results);
    }
    return meals;
  }

  Future<void> _loadCurrentPlan() async {
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      final page = await repo.listMealPlans(size: 20);
      if (page.content.isNotEmpty) {
        final plans = page.content;
        final plan = plans.first;
        final meals = await _entriesToMeals(plan.entries);
        state = MealPlanState(
          currentPlan: plan,
          meals: meals,
          availablePlans: plans,
        );
      } else {
        state = const MealPlanState();
      }
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectPlan(int index) async {
    final plans = state.availablePlans;
    if (index < 0 || index >= plans.length) return;
    final plan = plans[index];
    final meals = await _entriesToMeals(plan.entries);
    state = state.copyWith(
      currentPlan: plan,
      meals: meals,
      selectedPlanIndex: index,
    );
  }

  void navigatePrev() {
    final idx = state.selectedPlanIndex;
    if (idx < state.availablePlans.length - 1) {
      selectPlan(idx + 1);
    }
  }

  void navigateNext() {
    final idx = state.selectedPlanIndex;
    if (idx > 0) {
      selectPlan(idx - 1);
    }
  }

  Future<void> generateNewPlan() async {
    state = state.copyWith(isGenerating: true, clearError: true);
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      final plan = await repo.generateWeeklyPlan(startDate: _nextMonday());
      final meals = await _entriesToMeals(plan.entries);
      final updatedPlans = [plan, ...state.availablePlans];
      state = MealPlanState(
        currentPlan: plan,
        meals: meals,
        availablePlans: updatedPlans,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> replaceEntry(int index, MealPlanEntry newEntry) async {
    final plan = state.currentPlan;
    if (plan == null) return;
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      final oldEntry = plan.entries.length > index ? plan.entries[index] : null;
      if (oldEntry?.id != null) {
        await repo.deleteEntry(oldEntry!.id!);
      }
      final updatedPlan = await repo.addEntry(
        plan.id,
        recipeId: newEntry.recipeId!,
        mealDate: newEntry.mealDate!,
        mealType: newEntry.mealType!,
        servings: newEntry.servings ?? 1,
        notes: newEntry.notes,
      );
      final meals = await _entriesToMeals(updatedPlan.entries);
      state = state.copyWith(currentPlan: updatedPlan, meals: meals);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> removeEntry(int index) async {
    final plan = state.currentPlan;
    if (plan == null) return;
    try {
      final entry = plan.entries.length > index ? plan.entries[index] : null;
      if (entry?.id == null) return;
      final repo = ref.read(mealPlanRepositoryProvider);
      await repo.deleteEntry(entry!.id!);
      final updatedEntries = [...plan.entries]..removeAt(index);
      final updatedPlan = MealPlan(
        id: plan.id,
        name: plan.name,
        startDate: plan.startDate,
        endDate: plan.endDate,
        status: plan.status,
        entries: updatedEntries,
        createdAt: plan.createdAt,
        updatedAt: plan.updatedAt,
      );
      final meals = await _entriesToMeals(updatedEntries);
      state = state.copyWith(currentPlan: updatedPlan, meals: meals);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> activatePlan() async {
    final plan = state.currentPlan;
    if (plan == null) return;
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      await repo.activatePlan(plan.id);
      state = state.copyWith(
        currentPlan: MealPlan(
          id: plan.id,
          name: plan.name,
          startDate: plan.startDate,
          endDate: plan.endDate,
          status: 'ACTIVE',
          entries: plan.entries,
          createdAt: plan.createdAt,
          updatedAt: plan.updatedAt,
        ),
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> deletePlan() async {
    final plan = state.currentPlan;
    if (plan == null) return;
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      await repo.deleteMealPlan(plan.id);
      final updatedPlans = state.availablePlans.where((p) => p.id != plan.id).toList();
      state = updatedPlans.isNotEmpty
          ? MealPlanState(availablePlans: updatedPlans)
          : const MealPlanState();
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> refresh() => _loadCurrentPlan();
}

final mealPlanProvider = NotifierProvider<MealPlanNotifier, MealPlanState>(
  MealPlanNotifier.new,
);
