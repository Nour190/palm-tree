import 'dart:convert';
import '../resourses/app_secure_storage.dart';

class GlobalStorageUtils {
  static final AppSecureStorage _storage = AppSecureStorage();

  static Future<String?> getString(String key) async {
    return await _storage.getData(key);
  }

  static Future<void> setString(String key, String value) async {
    await _storage.setData(key: key, value: value);
  }

  static Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await _storage.getData(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _storage.setData(key: key, value: jsonString);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    return await getJson('user_data');
  }

  static Future<void> setUserData(Map<String, dynamic> userData) async {
    await setJson('user_data', userData);
  }

  static Future<String?> getUserId() async {
    final userData = await getUserData();
    return userData?['id'] as String?;
  }

  static Future<void> remove(String key) async {
    await _storage.removeData(key);
  }

  static Future<void> clearAll() async {
    await _storage.clear();
  }

  static Future<bool> hasKey(String key) async {
    final value = await _storage.getData(key);
    return value != null;
  }
}
