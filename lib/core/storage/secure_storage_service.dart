import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String tokenKey = 'tokenUser';

  static const String expiredAtKey = 'expiredAt';
  static const String userIdKey = 'userId';

  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: userIdKey, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }

  // SAVE TOKEN
  static Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  // SAVE EXPIRED TIME
  static Future<void> saveExpiredAt(String expiredAt) async {
    await _storage.write(key: expiredAtKey, value: expiredAt);
  }

  // GET TOKEN
  static Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  // GET EXPIRED TIME
  static Future<String?> getExpiredAt() async {
    return await _storage.read(key: expiredAtKey);
  }

  // CLEAR AUTH
  static Future<void> clearAuth() async {
    await _storage.delete(key: tokenKey);

    await _storage.delete(key: expiredAtKey);
    await _storage.delete(key: userIdKey);
  }

  // CLEAR ALL
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // CHECK VALID TOKEN
  static Future<String?> getValidToken() async {
    final token = await getToken();

    final expiredAtText = await getExpiredAt();

    if (token == null || expiredAtText == null) {
      return null;
    }

    final expiredAt = DateTime.parse(expiredAtText);

    if (DateTime.now().isAfter(expiredAt)) {
      await clearAuth();

      return null;
    }

    return token;
  }
}
