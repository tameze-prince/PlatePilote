class MealPlanDto {
  const MealPlanDto({
    required this.id,
    required this.title,
    required this.minutes,
    required this.kcal,
  });

  final String id;
  final String title;
  final int minutes;
  final int kcal;

  factory MealPlanDto.fromJson(Map<String, dynamic> json) {
    return MealPlanDto(
      id: json['id'] as String,
      title: json['title'] as String,
      minutes: json['minutes'] as int,
      kcal: json['kcal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'minutes': minutes, 'kcal': kcal};
  }
}
