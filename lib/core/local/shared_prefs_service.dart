import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  final SharedPreferences prefs;
  static const String _configKey = 'APP_CONFIG';

  SharedPrefsService(this.prefs);

  Future<void> saveConfig(Map<String, dynamic> config) async {
    try {
      final jsonString = json.encode(config);
      await prefs.setString(_configKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save config: $e');
    }
  }

  Map<String, dynamic>? getConfig() {
    try {
      final jsonString = prefs.getString(_configKey);
      if (jsonString == null) return null;

      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
