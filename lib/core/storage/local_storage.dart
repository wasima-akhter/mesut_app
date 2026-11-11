import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this._preferences);

  final SharedPreferences _preferences;

  // ==============================
  // String
  // ==============================
  String? getString(String key) => _preferences.getString(key);

  Future<bool> setString(String key, String value) =>
      _preferences.setString(key, value);

  // ==============================
  // Boolean
  // ==============================
  bool? getBool(String key) => _preferences.getBool(key);

  Future<bool> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  // ==============================
  // Integer
  // ==============================
  int? getInt(String key) => _preferences.getInt(key);

  Future<bool> setInt(String key, int value) =>
      _preferences.setInt(key, value);

  // ==============================
  // Double
  // ==============================
  double? getDouble(String key) => _preferences.getDouble(key);

  Future<bool> setDouble(String key, double value) =>
      _preferences.setDouble(key, value);

  // ==============================
  // Management
  // ==============================
  Future<bool> remove(String key) => _preferences.remove(key);

  Future<bool> clear() => _preferences.clear();

  bool containsKey(String key) => _preferences.containsKey(key);
}
