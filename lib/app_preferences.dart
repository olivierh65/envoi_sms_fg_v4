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

  double? getDouble(String key) => _prefs.getDouble(key);
  Future<void> setDouble(String key, double value) async =>
      await _prefs.setDouble(key, value);

  int? getInt(String key) => _prefs.getInt(key);
  Future<void> setInteger(String key, int value) async =>
      await _prefs.setInt(key, value);

  // Méthodes pour Duration (avec millisecondes)
  Future<void> setDuration(String key, Duration value) async {
    final String durationString =
        "${value.inMinutes.remainder(60).toString().padLeft(2, '0')}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}.${value.inMilliseconds.remainder(1000).toString().padLeft(3, '0')}";
    await _prefs.setString(key, durationString); // Stockage en String
  }

  Duration? getDuration(String key) {
    final durationString = _prefs.getString(key);
    if (durationString != null) {
      final parts = durationString.split(':');
      if (parts.length == 2) {
        final subParts = parts[1].split('.');
        if (subParts.length == 2) {
          final minutes = int.tryParse(parts[0]) ?? 0;
          final seconds = int.tryParse(subParts[0]) ?? 0;
          final milliseconds = int.tryParse(subParts[1]) ?? 0;
          return Duration(minutes: minutes, seconds: seconds, milliseconds: milliseconds);
        }
      }
    }
    return null;
  }
  containsKey(String key) => _prefs.containsKey(key);

}
