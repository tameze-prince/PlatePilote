/// DTO simplifié pour un repas dans le plan.
class MealPlanDto {
  const MealPlanDto({
    required this.id,
    required this.title,
    required this.minutes,
    required this.kcal,
  });

  /// Identifiant unique.
  final String id;
  /// Titre du repas.
  final String title;
  /// Temps de préparation en minutes.
  final int minutes;
  /// Calories du repas.
  final int kcal;

  /// Crée un [MealPlanDto] depuis une map JSON.
  factory MealPlanDto.fromJson(Map<String, dynamic> json) {
    return MealPlanDto(
      id: json['id'] as String,
      title: json['title'] as String,
      minutes: json['minutes'] as int,
      kcal: json['kcal'] as int,
    );
  }

  /// Convertit ce [MealPlanDto] en map JSON.
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'minutes': minutes, 'kcal': kcal};
  }
}
