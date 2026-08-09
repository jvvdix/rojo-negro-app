import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists which screen the player was on so refreshing the page (very easy
/// to do by accident on a phone browser mid-game) doesn't dump them back to
/// the home menu and lose an in-progress game.
class SessionStorage {
  static const _key = 'baraja_party_session_v1';

  static Future<void> save(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(json));
  }

  static Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
