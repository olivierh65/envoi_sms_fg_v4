import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();
  static late final SharedPreferences _prefs;

  factory AppPreferences() {
    return _instance;
  }

  AppPreferences._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Méthodes utilitaires pour accéder aux préférences
  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<void> setBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  containsKey(String key) => _prefs.containsKey(key);
}
