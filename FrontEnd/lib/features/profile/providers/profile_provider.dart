import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/preferences_provider.dart';
import '../../../core/repositories/profile_repository.dart';
import '../../auth/providers/auth_provider.dart';

class UserProfile {
  const UserProfile({
    this.displayName = '',
    this.email = '',
    this.heightCm,
    this.weightKg,
    this.dateOfBirth,
    this.gender,
    this.activityLevel,
    this.countryCode = 'US',
    this.currencyCode = 'USD',
    this.locale = 'en-US',
    this.cookingSkill,
    this.householdSize,
    this.healthGoals,
    this.avatarBytes,
  });

  final String displayName;
  final String email;
  final double? heightCm;
  final double? weightKg;
  final String? dateOfBirth;
  final String? gender;
  final String? activityLevel;
  final String countryCode;
  final String currencyCode;
  final String locale;
  final String? cookingSkill;
  final int? householdSize;
  final String? healthGoals;
  final String? avatarBytes;

  int? get age {
    if (dateOfBirth == null) return null;
    try {
      final date = DateTime.parse(dateOfBirth!);
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  int get completeness {
    int score = 0;
    if (gender != null) score++;
    if (heightCm != null) score++;
    if (weightKg != null) score++;
    if (dateOfBirth != null) score++;
    if (activityLevel != null) score++;
    if (cookingSkill != null) score++;
    if (householdSize != null) score++;
    if (healthGoals != null && healthGoals!.isNotEmpty) score++;
    return score;
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    double? heightCm,
    double? weightKg,
    String? dateOfBirth,
    String? gender,
    String? activityLevel,
    String? countryCode,
    String? currencyCode,
    String? locale,
    String? cookingSkill,
    int? householdSize,
    String? healthGoals,
    String? avatarBytes,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      locale: locale ?? this.locale,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      householdSize: householdSize ?? this.householdSize,
      healthGoals: healthGoals ?? this.healthGoals,
      avatarBytes: avatarBytes ?? this.avatarBytes,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'email': email,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'activityLevel': activityLevel,
        'countryCode': countryCode,
        'currencyCode': currencyCode,
        'locale': locale,
        'cookingSkill': cookingSkill,
        'householdSize': householdSize,
        'healthGoals': healthGoals,
        'avatarBytes': avatarBytes,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      activityLevel: json['activityLevel'] as String?,
      countryCode: json['countryCode'] as String? ?? 'US',
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      locale: json['locale'] as String? ?? 'en-US',
      cookingSkill: json['cookingSkill'] as String?,
      householdSize: json['householdSize'] as int?,
      healthGoals: json['healthGoals'] as String?,
      avatarBytes: json['avatarBytes'] as String?,
    );
  }
}

class ProfileNotifier extends Notifier<UserProfile> {
  static const _key = 'profile.user';
  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  @override
  UserProfile build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_key);
    if (stored != null) {
      return UserProfile.fromJson(
        json.decode(stored) as Map<String, dynamic>,
      );
    }
    return const UserProfile();
  }

  Future<void> loadFromApi() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final apiProfile = await repo.getProfile();
      final authState = ref.read(authProvider);
      state = UserProfile(
        displayName: _buildDisplayName(apiProfile, authState.name),
        email: authState.email ?? '',
        heightCm: (apiProfile['heightCm'] as num?)?.toDouble(),
        weightKg: (apiProfile['weightKg'] as num?)?.toDouble(),
        dateOfBirth: apiProfile['dateOfBirth'] as String?,
        gender: apiProfile['gender'] as String?,
        activityLevel: apiProfile['activityLevel'] as String?,
        countryCode: apiProfile['countryCode'] as String? ?? 'US',
        currencyCode: apiProfile['currencyCode'] as String? ?? 'USD',
        locale: apiProfile['locale'] as String? ?? 'en-US',
        cookingSkill: apiProfile['cookingSkill'] as String?,
        householdSize: apiProfile['householdSize'] as int?,
        healthGoals: apiProfile['healthGoals'] as String?,
      );
      _hasUnsavedChanges = false;
      await _persist();
    } catch (_) {}
  }

  Future<void> updateProfile({
    String? displayName,
    String? email,
    String? dateOfBirth,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? countryCode,
    String? currencyCode,
    String? cookingSkill,
    int? householdSize,
    String? healthGoals,
    String? avatarBytes,
  }) async {
    state = state.copyWith(
      displayName: displayName,
      email: email,
      dateOfBirth: dateOfBirth,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
      countryCode: countryCode,
      currencyCode: currencyCode,
      cookingSkill: cookingSkill,
      householdSize: householdSize,
      healthGoals: healthGoals,
      avatarBytes: avatarBytes,
    );
    _hasUnsavedChanges = true;
    await _persist();
  }

  Future<void> saveToApi() async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.updateProfile(
      dateOfBirth: state.dateOfBirth,
      gender: state.gender,
      heightCm: state.heightCm,
      weightKg: state.weightKg,
      activityLevel: state.activityLevel,
      countryCode: state.countryCode,
      currencyCode: state.currencyCode,
      cookingSkill: state.cookingSkill,
      householdSize: state.householdSize,
      healthGoals: state.healthGoals,
    );
    _hasUnsavedChanges = false;
  }

  Future<void> setAvatarBytes(String? bytes) async {
    state = state.copyWith(avatarBytes: bytes);
    _hasUnsavedChanges = true;
    await _persist();
  }

  Future<void> _persist() async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, json.encode(state.toJson()));
  }

  String _buildDisplayName(Map<String, dynamic> apiProfile, String? authName) {
    if (authName != null && authName.isNotEmpty) return authName;
    final firstName = apiProfile['firstName'] as String?;
    final lastName = apiProfile['lastName'] as String?;
    if (firstName != null && lastName != null) return '$firstName $lastName';
    return state.displayName;
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);

final profileCompletenessProvider = Provider<double>((ref) {
  final profile = ref.watch(profileProvider);
  const totalFields = 8;
  return profile.completeness / totalFields;
});
