import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

/// Repository d'authentification gérant la connexion, l'inscription,
/// le rafraîchissement de token, la vérification email et les mots de passe oubliés.
class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Connecte l'utilisateur avec [email] et [password].
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

  /// Inscrit un nouvel utilisateur avec les informations personnelles.
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

  /// Rafraîchit le token d'accès à l'aide du [refreshToken].
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

  /// Vérifie l'adresse email avec le [token] de vérification.
  Future<bool> verifyEmail(String token) async {
    try {
      await _apiClient.post('/auth/verify-email', query: {'token': token});
      return true;
    } on DioException {
      return false;
    }
  }

  /// Renvoie l'email de vérification à l'adresse donnée.
  Future<bool> resendVerification(String email) async {
    try {
      await _apiClient.post('/auth/resend-verification', data: {'email': email});
      return true;
    } on DioException {
      return false;
    }
  }

  /// Déconnecte l'utilisateur en invalidant le [refreshToken] côté serveur.
  Future<bool> logout({required String refreshToken}) async {
    try {
      await _apiClient.post('/auth/logout', data: {'refreshToken': refreshToken});
      return true;
    } on DioException {
      return false;
    }
  }

  /// Valide la session actuelle en appelant un endpoint protégé.
  /// Retourne l'email extrait du JWT en cas de succès.
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

  /// Décode le payload du JWT pour extraire l'email (claim subject).
  /// Opération côté client uniquement — sans appel réseau.
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

  /// Envoie une demande de réinitialisation de mot de passe pour [email].
  Future<bool> forgotPassword(String email) async {
    try {
      await _apiClient.post('/auth/forgot-password', data: {'email': email});
      return true;
    } on DioException {
      return false;
    }
  }

  /// Réinitialise le mot de passe avec [token] et [newPassword].
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
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
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

/// Résultat d'une opération d'authentification contenant le statut,
/// les tokens JWT et un éventuel message d'erreur.
class AuthResult {
  const AuthResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.data,
    this.message,
  });

  /// Indique si l'opération a réussi.
  final bool success;

  /// Token d'accès JWT.
  final String? accessToken;

  /// Token de rafraîchissement JWT.
  final String? refreshToken;

  /// Données utilisateur optionnelles.
  final AuthUserData? data;

  /// Message d'erreur ou d'information.
  final String? message;
}

/// Données utilisateur extraites après une authentification réussie.
class AuthUserData {
  const AuthUserData({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
  });

  /// Identifiant unique de l'utilisateur.
  final int id;

  /// Adresse email de l'utilisateur.
  final String email;

  /// Prénom de l'utilisateur.
  final String? firstName;

  /// Nom de famille de l'utilisateur.
  final String? lastName;
}

/// Provider Riverpod pour [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
  );
});
