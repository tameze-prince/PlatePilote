/// Modèle représentant un utilisateur.
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

  /// Identifiant unique.
  final String id;
  /// Adresse email.
  final String email;
  /// Prénom.
  final String? firstName;
  /// Nom de famille.
  final String? lastName;
  /// Date de naissance.
  final String? dateOfBirth;
  /// Genre.
  final String? gender;
  /// Taille en cm.
  final double? heightCm;
  /// Poids en kg.
  final double? weightKg;
  /// Niveau d'activité.
  final String? activityLevel;
  /// Objectifs de santé.
  final String? healthGoals;
  /// Code pays.
  final String? countryCode;
  /// Code devise.
  final String? currencyCode;
  /// Locale préférée.
  final String? locale;
  /// Niveau de compétence culinaire.
  final String? cookingSkill;
  /// Taille du foyer.
  final int? householdSize;
  /// Date de création du compte.
  final String? createdAt;

  /// Nom d'affichage complet.
  String get displayName {
    if (firstName != null && lastName != null) return '$firstName $lastName';
    if (firstName != null) return firstName!;
    return email;
  }

  /// Crée un [User] depuis une map JSON.
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

  /// Convertit cet [User] en map JSON.
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
