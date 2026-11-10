import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interface abstraite pour le stockage sécurisé des tokens JWT.
abstract class TokenStorage {
  /// Sauvegarde les tokens d'accès et de rafraîchissement.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Récupère le token d'accès.
  Future<String?> getAccessToken();

  /// Récupère le token de rafraîchissement.
  Future<String?> getRefreshToken();

  /// Efface tous les tokens stockés.
  Future<void> clearTokens();

  /// Vérifie si des tokens sont présents.
  Future<bool> hasTokens();
}

/// Implémentation native de [TokenStorage] utilisant [FlutterSecureStorage]
/// pour les appareils mobiles (Android, iOS).
class NativeTokenStorage implements TokenStorage {
  NativeTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  @override
  Future<bool> hasTokens() async {
    final access = await _storage.read(key: _accessTokenKey);
    return access != null;
  }
}

/// Implémentation web non persistante de [TokenStorage].
///
/// Les JWT ne sont jamais écrits dans localStorage / IndexedDB. Ils restent
/// uniquement en mémoire pendant la durée de vie de la page. Une actualisation
/// du navigateur ferme donc la session et impose une nouvelle authentification.
/// Pour une session web persistante, utiliser des cookies HttpOnly/Secure côté
/// serveur plutôt que de rendre un refresh token accessible au JavaScript.
class WebTokenStorage implements TokenStorage {
  final Map<String, String> _tokens = <String, String>{};

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _tokens[_accessTokenKey] = accessToken;
    _tokens[_refreshTokenKey] = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _tokens[_accessTokenKey];

  @override
  Future<String?> getRefreshToken() async => _tokens[_refreshTokenKey];

  @override
  Future<void> clearTokens() async => _tokens.clear();

  @override
  Future<bool> hasTokens() async => _tokens.containsKey(_accessTokenKey);
}

/// Provider Riverpod pour [TokenStorage].
/// Les plateformes natives utilisent le stockage sécurisé du système ; le web
/// utilise un stockage mémoire non persistant pour éviter les JWT persistants
/// accessibles au JavaScript.
final secureStorageProvider = Provider<TokenStorage>((ref) {
  if (kIsWeb) return WebTokenStorage();
  return NativeTokenStorage(const FlutterSecureStorage());
});
