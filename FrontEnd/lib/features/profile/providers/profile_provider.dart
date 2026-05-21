import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/preferences_provider.dart';

class UserProfile {
  const UserProfile({
    this.displayName = 'Sarah Parker',
    this.email = 'sarah.parker@example.com',
    this.height,
    this.weight,
    this.age,
    this.gender,
  });

  final String displayName;
  final String email;
  final double? height;
  final double? weight;
  final int? age;
  final String? gender;

  UserProfile copyWith({
    String? displayName,
    String? email,
    double? height,
    double? weight,
    int? age,
    String? gender,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'email': email,
        'height': height,
        'weight': weight,
        'age': age,
        'gender': gender,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['displayName'] as String? ?? 'Sarah Parker',
      email: json['email'] as String? ?? 'sarah.parker@example.com',
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      age: json['age'] as int?,
      gender: json['gender'] as String?,
    );
  }
}

class ProfileNotifier extends Notifier<UserProfile> {
  static const _key = 'profile.user';

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

  Future<void> setDisplayName(String value) async {
    state = state.copyWith(displayName: value);
    await _persist();
  }

  Future<void> setEmail(String value) async {
    state = state.copyWith(email: value);
    await _persist();
  }

  Future<void> setHeight(double? value) async {
    state = state.copyWith(height: value);
    await _persist();
  }

  Future<void> setWeight(double? value) async {
    state = state.copyWith(weight: value);
    await _persist();
  }

  Future<void> setAge(int? value) async {
    state = state.copyWith(age: value);
    await _persist();
  }

  Future<void> setGender(String? value) async {
    state = state.copyWith(gender: value);
    await _persist();
  }

  Future<void> _persist() async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, json.encode(state.toJson()));
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
