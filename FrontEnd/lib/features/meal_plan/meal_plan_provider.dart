import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';
import '../../shared/models/demo_data.dart';

class MealPlanState {
  const MealPlanState({
    this.meals = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Meal> meals;
  final bool isLoading;
  final String? error;
}

class MealPlanNotifier extends Notifier<MealPlanState> {
  static const _key = 'mealPlan.meals';

  @override
  MealPlanState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    if (stored != null) {
      final list = (json.decode(stored) as List)
          .map((e) => _mealFromJson(e as Map<String, dynamic>))
          .toList();
      return MealPlanState(meals: list);
    }
    return const MealPlanState(meals: demoMeals);
  }

  Future<void> regeneratePlan() async {
    state = MealPlanState(isLoading: true);
    // TODO: call service to regenerate plan
    await Future.delayed(const Duration(milliseconds: 300));
    state = MealPlanState(meals: state.meals, isLoading: false);
    await _persist();
  }

  Future<void> replaceMeal(int index, Meal replacement) async {
    final meals = [...state.meals];
    meals[index] = replacement;
    state = MealPlanState(meals: meals);
    await _persist();
  }

  Future<void> toggleLock(int index) async {
    final meal = state.meals[index];
    final updated = Meal(
      day: meal.day,
      type: meal.type,
      title: meal.title,
      minutes: meal.minutes,
      kcal: meal.kcal,
      icon: meal.icon,
      tint: meal.tint,
      locked: !meal.locked,
    );
    final meals = [...state.meals];
    meals[index] = updated;
    state = MealPlanState(meals: meals);
    await _persist();
  }

  Future<void> _persist() async {
    final encoded = state.meals.map(_mealToJson).toList();
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, jsonEncode(encoded));
  }

  Map<String, dynamic> _mealToJson(Meal meal) => {
    'day': meal.day,
    'type': meal.type,
    'title': meal.title,
    'minutes': meal.minutes,
    'kcal': meal.kcal,
    'iconCodePoint': meal.icon.codePoint,
    'tintValue': meal.tint.toARGB32(),
    'locked': meal.locked,
  };

  Meal _mealFromJson(Map<String, dynamic> json) {
    return Meal(
      day: json['day'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      minutes: json['minutes'] as int,
      kcal: json['kcal'] as int,
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      tint: Color(json['tintValue'] as int),
      locked: json['locked'] as bool? ?? false,
    );
  }
}

final mealPlanProvider = NotifierProvider<MealPlanNotifier, MealPlanState>(
  MealPlanNotifier.new,
);
