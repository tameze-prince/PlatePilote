import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/base_repository.dart';
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
  });

  final MealPlan? currentPlan;
  final List<Meal> meals;
  final bool isLoading;
  final bool isGenerating;
  final String? error;

  MealPlanState copyWith({
    MealPlan? currentPlan,
    List<Meal>? meals,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    bool clearError = false,
  }) {
    return MealPlanState(
      currentPlan: currentPlan ?? this.currentPlan,
      meals: meals ?? this.meals,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : (error ?? this.error),
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

  List<Meal> _entriesToMeals(List<MealPlanEntry> entries) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return entries.map((entry) {
      final date = entry.mealDate != null ? DateTime.tryParse(entry.mealDate!) : null;
      final dayName = date != null ? dayNames[date.weekday - 1] : (entry.mealDate ?? '');
      return Meal(
        day: dayName,
        type: entry.mealType ?? 'Meal',
        title: entry.recipeName ?? 'Unknown Recipe',
        minutes: 25,
        kcal: 450,
        icon: Icons.restaurant,
        tint: Colors.green,
        imageUrl: null,
      );
    }).toList();
  }

  Future<void> _loadCurrentPlan() async {
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      final page = await repo.listMealPlans(size: 1);
      if (page.content.isNotEmpty) {
        final plan = page.content.first;
        final meals = _entriesToMeals(plan.entries);
        state = MealPlanState(
          currentPlan: plan,
          meals: meals,
        );
      }
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> generateNewPlan() async {
    state = state.copyWith(isGenerating: true, clearError: true);
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      final plan = await repo.generateWeeklyPlan(startDate: _nextMonday());
      final meals = _entriesToMeals(plan.entries);
      state = MealPlanState(
        currentPlan: plan,
        meals: meals,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.message,
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
      final meals = _entriesToMeals(updatedPlan.entries);
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
      final meals = _entriesToMeals(updatedEntries);
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
      state = const MealPlanState();
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> refresh() => _loadCurrentPlan();
}

final mealPlanProvider = NotifierProvider<MealPlanNotifier, MealPlanState>(
  MealPlanNotifier.new,
);
