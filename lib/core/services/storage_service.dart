import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/* 
STORAGE SERVICE:
- Recent searches, favorites, aur API caching handle karta hai.
- SharedPreferences use karke data persist kiya jata hai.
*/
class StorageService {
  static late SharedPreferences _prefs;

  // Initialize service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic Save
  static Future<void> save(String key, dynamic value) async {
    if (value is String) await _prefs.setString(key, value);
    if (value is bool) await _prefs.setBool(key, value);
    if (value is int) await _prefs.setInt(key, value);
    if (value is double) await _prefs.setDouble(key, value);
    if (value is List<String>) await _prefs.setStringList(key, value);
  }

  // Generic Get
  static dynamic get(String key) => _prefs.get(key);

  // History Management
  static Future<void> addHistory(String key, String item) async {
    List<String> history = _prefs.getStringList(key) ?? [];
    if (!history.contains(item)) {
      history.insert(0, item);
      if (history.length > 10) history.removeLast(); // Limit history to 10
      await _prefs.setStringList(key, history);
    }
  }

  static List<String> getHistory(String key) => _prefs.getStringList(key) ?? [];

  // Favorites Management
  static Future<void> toggleFavorite(String key, String item) async {
    List<String> favs = _prefs.getStringList(key) ?? [];
    if (favs.contains(item)) {
      favs.remove(item);
    } else {
      favs.add(item);
    }
    await _prefs.setStringList(key, favs);
  }

  static bool isFavorite(String key, String item) {
    List<String> favs = _prefs.getStringList(key) ?? [];
    return favs.contains(item);
  }

  // API Caching (Simple JSON cache)
  static Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final cacheObj = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data
    };
    await _prefs.setString(key, json.encode(cacheObj));
  }

  static Map<String, dynamic>? getCachedData(String key, {int expiryMinutes = 30}) {
    final cachedStr = _prefs.getString(key);
    if (cachedStr == null) return null;

    final cacheObj = json.decode(cachedStr);
    final timestamp = cacheObj['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if cache is expired
    if (now - timestamp > expiryMinutes * 60 * 1000) {
      return null;
    }

    return cacheObj['data'];
  }
}
