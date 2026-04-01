import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const _rememberMeKey = 'remember_me';
  static const _savedEmailKey = 'saved_email';
  static const _savedPasswordKey = 'saved_password';
  static const _tokenKey = 'auth_token';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> saveRememberLogin({
    required bool rememberMe,
    required String email,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);

    if (rememberMe) {
      await prefs.setString(_savedEmailKey, email);

      if (password != null && password.isNotEmpty) {
        await _secureStorage.write(key: _savedPasswordKey, value: password);
      }
    } else {
      await prefs.remove(_savedEmailKey);
      await _secureStorage.delete(key: _savedPasswordKey);
    }
  }

  static Future<Map<String, dynamic>> getRememberLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    final email = prefs.getString(_savedEmailKey) ?? '';
    final password = await _secureStorage.read(key: _savedPasswordKey);

    return {
      'rememberMe': rememberMe,
      'email': email,
      'password': password ?? '',
    };
  }

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  static Future<void> clearAllRememberData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_savedEmailKey);
    await _secureStorage.delete(key: _savedPasswordKey);
    await _secureStorage.delete(key: _tokenKey);
  }
}
