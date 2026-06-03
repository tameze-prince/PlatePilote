import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/preferences_provider.dart';

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

/// Implémentation web de [TokenStorage] utilisant [SharedPreferences]
/// (car FlutterSecureStorage n'est pas disponible sur le web).
class WebTokenStorage implements TokenStorage {
  WebTokenStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _accessTokenKey = 'web_access_token';
  static const _refreshTokenKey = 'web_refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _prefs.setString(_accessTokenKey, accessToken),
      _prefs.setString(_refreshTokenKey, refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() async => _prefs.getString(_accessTokenKey);

  @override
  Future<String?> getRefreshToken() async => _prefs.getString(_refreshTokenKey);

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _prefs.remove(_accessTokenKey),
      _prefs.remove(_refreshTokenKey),
    ]);
  }

  @override
  Future<bool> hasTokens() async {
    return _prefs.containsKey(_accessTokenKey);
  }
}

/// Provider Riverpod pour [TokenStorage].
/// Utilise [NativeTokenStorage] sur mobile et [WebTokenStorage] sur le web.
final secureStorageProvider = Provider<TokenStorage>((ref) {
  if (kIsWeb) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return WebTokenStorage(prefs);
  }
  return NativeTokenStorage(const FlutterSecureStorage());
});
