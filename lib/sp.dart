import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储
class SpUtil {
  SpUtil._();
  static SpUtil _instance = new SpUtil._();
  static SpUtil get instance => _instance;
  factory SpUtil() => _instance;

  static SharedPreferences _prefs;


  static Future<void> init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<bool> setJSON(String key, dynamic jsonVal) {
    String jsonString = jsonEncode(jsonVal);
    return _prefs.setString(key, jsonString);
  }

  dynamic getJSON(String key) {
    String jsonString = _prefs.getString(key);
    return jsonString == null ? null : jsonDecode(jsonString);
  }

  Future<bool> set(String key, dynamic val) {
    return _prefs.setString(key, val);
  }

  dynamic get(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setBool(String key, bool val) {
    return _prefs.setBool(key, val);
  }

  bool getBool(String key) {
    bool val = _prefs.getBool(key);
    return val == null ? false : val;
  }

  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }
}