class User {
  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.healthGoals,
    this.countryCode,
    this.currencyCode,
    this.locale,
    this.cookingSkill,
    this.householdSize,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel;
  final String? healthGoals;
  final String? countryCode;
  final String? currencyCode;
  final String? locale;
  final String? cookingSkill;
  final int? householdSize;
  final String? createdAt;

  String get displayName {
    if (firstName != null && lastName != null) return '$firstName $lastName';
    if (firstName != null) return firstName!;
    return email;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'] as String?,
      healthGoals: json['healthGoals'] as String?,
      countryCode: json['countryCode'] as String?,
      currencyCode: json['currencyCode'] as String?,
      locale: json['locale'] as String?,
      cookingSkill: json['cookingSkill'] as String?,
      householdSize: json['householdSize'] as int?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel,
      'healthGoals': healthGoals,
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'locale': locale,
      'cookingSkill': cookingSkill,
      'householdSize': householdSize,
    };
  }
}
