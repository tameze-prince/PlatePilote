import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../network/api_client.dart';

/// Repository pour la connexion sociale OAuth2 (Google, Apple).
/// Tous les tokens sont validés côté serveur — l'application ne stocke que les JWT.
class OAuth2Repository {
  OAuth2Repository(this._apiClient);

  final ApiClient _apiClient;

  // ── Google ──────────────────────────────────────────────

  /// Déclenche le flux de connexion Google et retourne le résultat du serveur.
  /// Retourne `null` si l'utilisateur annule ou si une erreur se produit.
  Future<OAuth2SignInResult?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: _googleServerClientId,
      scopes: ['openid', 'email', 'profile'],
    );

    try {
      final account = await googleSignIn.signIn();
      if (account == null) return null; // User cancelled

      final auth = await googleSignIn.currentUser?.authentication;
      if (auth == null) return null;

      final idToken = auth.idToken;
      if (idToken == null) return null;

      return await _verifyTokenWithBackend(provider: 'google', idToken: idToken);
    } on Exception catch (e) {
      return OAuth2SignInResult(success: false, errorMessage: e.toString());
    }
  }

  /// ID client émis par le serveur pour l'application web OAuth2 du backend.
  /// Sur mobile, c'est le même ID client utilisé par le SDK Google Sign-In.
  String? get _googleServerClientId => null; // Set via env var if needed

  // ── Apple ───────────────────────────────────────────────

  /// Déclenche Sign in with Apple et retourne le résultat du serveur.
  Future<OAuth2SignInResult?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // Provide the same redirect URI your backend uses for Apple token exchange.
        // Must match what's registered in the Apple Services ID.
        // For server-side validation, we use the same redirect URI approach.
      );

      // Apple gives us an authorization code — exchange it for an id_token
      // if the backend supports code exchange, or pass the raw token for validation.
      // Sign in with Apple works differently than Google — we receive:
      //   - authorizationCode: for server-side token exchange
      //   - identityToken: the OIDC id_token (same as Google)
      //   - email / fullName: only on first sign-in

      final idToken = credential.identityToken;
      if (idToken == null) {
        return OAuth2SignInResult(
          success: false,
          errorMessage: 'Apple returned no identity token',
        );
      }

      return await _verifyTokenWithBackend(provider: 'apple', idToken: idToken);
    } on Exception catch (e) {
      return OAuth2SignInResult(success: false, errorMessage: e.toString());
    }
  }

  // ── Backend verification ────────────────────────────────

  /// Envoie le jeton idToken/accessToken du fournisseur OAuth2 à notre backend
  /// pour validation, création / liaison d'utilisateur, et émission de JWT.
  Future<OAuth2SignInResult> _verifyTokenWithBackend({
    required String provider,
    required String idToken,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/oauth2',
        data: {
          'provider': provider,
          'idToken': idToken,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      return OAuth2SignInResult(
        success: true,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      return OAuth2SignInResult(
        success: false,
        errorMessage: _extractMessage(e.response),
      );
    }
  }

  String _extractMessage(Response<dynamic>? response) {
    if (response?.data is Map) {
      final msg = (response!.data as Map)['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return 'OAuth2 sign-in failed';
  }
}

/// Résultat d'une tentative de connexion OAuth2.
class OAuth2SignInResult {
  const OAuth2SignInResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });

  /// Indique si la connexion a réussi.
  final bool success;

  /// Token d'accès JWT (présent en cas de succès).
  final String? accessToken;

  /// Token de rafraîchissement JWT (présent en cas de succès).
  final String? refreshToken;

  /// Message d'erreur (présent en cas d'échec).
  final String? errorMessage;
}

// ── Provider ────────────────────────────────────────────────────────────────

/// Provider Riverpod pour [OAuth2Repository].
final oAuth2RepositoryProvider = Provider<OAuth2Repository>((ref) {
  return OAuth2Repository(ref.watch(apiClientProvider));
});