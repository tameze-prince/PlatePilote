import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _handleAuthResponse(response);
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _extractMessage(e.response),
      );
    }
  }

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        },
      );
      return _handleAuthResponse(response);
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _extractMessage(e.response),
      );
    }
  }

  Future<AuthResult> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        query: {'refreshToken': refreshToken},
      );
      return _handleAuthResponse(response);
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _extractMessage(e.response),
      );
    }
  }

  Future<bool> verifyEmail(String token) async {
    try {
      await _apiClient.post('/auth/verify-email', query: {'token': token});
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> resendVerification(String email) async {
    try {
      await _apiClient.post('/auth/resend-verification', data: {'email': email});
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> logout({required String refreshToken}) async {
    try {
      await _apiClient.post('/auth/logout', data: {'refreshToken': refreshToken});
      return true;
    } on DioException {
      return false;
    }
  }

  /// Validates the current session by calling a protected endpoint.
  /// Returns the email extracted from the JWT if successful.
  Future<AuthResult> validateSession() async {
    try {
      await _apiClient.get('/profile');
      return AuthResult(success: true);
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _extractMessage(e.response),
      );
    }
  }

  /// Decodes the JWT payload to extract the email (subject claim).
  /// This is a client-side only operation — no network call.
  static String? extractEmailFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(parts[1]));
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return json['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _apiClient.post('/auth/forgot-password', data: {'email': email});
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      await _apiClient.post(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );
      return true;
    } on DioException {
      return false;
    }
  }

  AuthResult _handleAuthResponse(Response<dynamic> response) {
    final data = response.data['data'] as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    return AuthResult(
      success: true,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  String _extractMessage(Response<dynamic>? response) {
    if (response?.data is Map) {
      final msg = (response!.data as Map)['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return 'An unexpected error occurred';
  }
}

class AuthResult {
  const AuthResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.data,
    this.message,
  });

  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final AuthUserData? data;
  final String? message;
}

class AuthUserData {
  const AuthUserData({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
  });

  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
  );
});
