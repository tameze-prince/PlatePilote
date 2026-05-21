import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/preferences_provider.dart';

abstract class TokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<bool> hasTokens();
}

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

final secureStorageProvider = Provider<TokenStorage>((ref) {
  if (kIsWeb) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return WebTokenStorage(prefs);
  }
  return NativeTokenStorage(const FlutterSecureStorage());
});
