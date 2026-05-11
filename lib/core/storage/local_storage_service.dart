import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _rememberMeKey = 'remember_me';

  static const _savedEmailKey = 'saved_email';

  static Future<void> saveRememberLogin({
    required bool rememberMe,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_rememberMeKey, rememberMe);

    if (rememberMe) {
      await prefs.setString(_savedEmailKey, email);
    } else {
      await prefs.remove(_savedEmailKey);
    }
  }

  static Future<Map<String, dynamic>> getRememberLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

    final email = prefs.getString(_savedEmailKey) ?? '';

    return {'rememberMe': rememberMe, 'email': email};
  }

  static Future<void> clearAllRememberData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_rememberMeKey);

    await prefs.remove(_savedEmailKey);
  }
}
