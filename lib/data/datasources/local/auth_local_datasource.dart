import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../domain/entities/user.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  static const _keyToken = 'auth_token';
  static const _keyUser = 'current_user';
  static const _keyIsLoggedIn = 'is_logged_in';

  AuthLocalDataSource(this._secureStorage, this._prefs);

  /// Save authentication token securely
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  /// Save current user data
  Future<void> saveUser(User user) async {
    await _prefs.setString(_keyUser, json.encode(user.toJson()));
    await _prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Get current user data
  Future<User?> getUser() async {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;

    try {
      return User.fromJson(json.decode(userJson));
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Clear all authentication data
  Future<void> clearAuth() async {
    await _secureStorage.delete(key: _keyToken);
    await _prefs.remove(_keyUser);
    await _prefs.setBool(_keyIsLoggedIn, false);
  }
}
