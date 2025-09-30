import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  AppSecureStorage._();
  static final AppSecureStorage _instance = AppSecureStorage._();
  factory AppSecureStorage() => _instance;

  late final FlutterSecureStorage instance;

  Future init() async {
    instance = const FlutterSecureStorage();
  }

  Future<String?> getData(String key) async {
    return await instance.read(key: key);
  }
  Future<Map<String,String>> getAllData() async {
    return await instance.readAll();
  }

  Future setData({required String key, required String value}) async {
    await instance.write(key: key, value: value);
  }

  Future removeData(String key) async {
    await instance.delete(key: key);
  }

  Future clear() async {
    await instance.deleteAll();
  }
}
