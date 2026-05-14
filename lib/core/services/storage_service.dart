import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/* 
STORAGE SERVICE v4:
- Added support for Saved Commands.
- Added support for Favorite Skins/Capes.
- Added JSON Backup system.
*/
class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> save(String key, dynamic value) async {
    if (value is String) await _prefs.setString(key, value);
    if (value is bool) await _prefs.setBool(key, value);
    if (value is int) await _prefs.setInt(key, value);
    if (value is double) await _prefs.setDouble(key, value);
    if (value is List<String>) await _prefs.setStringList(key, value);
  }

  static dynamic get(String key) => _prefs.get(key);

  static Future<void> addHistory(String key, String item) async {
    List<String> history = _prefs.getStringList(key) ?? [];
    history.remove(item); // Duplicate hatao
    history.insert(0, item);
    if (history.length > 15) history.removeLast(); 
    await _prefs.setStringList(key, history);
  }

  static List<String> getHistory(String key) => _prefs.getStringList(key) ?? [];

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

  // Saved Commands System
  static Future<void> saveCommand(String name, String cmd) async {
    Map<String, String> saved = getSavedCommands();
    saved[name] = cmd;
    await _prefs.setString('saved_commands', json.encode(saved));
  }

  static Map<String, String> getSavedCommands() {
    String? raw = _prefs.getString('saved_commands');
    if (raw == null) return {};
    return Map<String, String>.from(json.decode(raw));
  }

  static Future<void> deleteCommand(String name) async {
    Map<String, String> saved = getSavedCommands();
    saved.remove(name);
    await _prefs.setString('saved_commands', json.encode(saved));
  }

  // Backup System (JSON)
  static String exportBackup() {
    Map<String, dynamic> allData = {};
    for (String key in _prefs.getKeys()) {
      allData[key] = _prefs.get(key);
    }
    return json.encode(allData);
  }

  static Future<void> importBackup(String jsonStr) async {
    try {
      Map<String, dynamic> data = json.decode(jsonStr);
      for (var entry in data.entries) {
        if (entry.value is String) await _prefs.setString(entry.key, entry.value);
        if (entry.value is bool) await _prefs.setBool(entry.key, entry.value);
        if (entry.value is int) await _prefs.setInt(entry.key, entry.value);
        if (entry.value is double) await _prefs.setDouble(entry.key, entry.value);
        if (entry.value is List) {
           await _prefs.setStringList(entry.key, List<String>.from(entry.value));
        }
      }
    } catch (e) {
      print('Backup import error: $e');
    }
  }

  // API Caching
  static Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final cacheObj = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data
    };
    await _prefs.setString('cache_$key', json.encode(cacheObj));
  }

  static Map<String, dynamic>? getCachedData(String key, {int expiryMinutes = 60}) {
    final cachedStr = _prefs.getString('cache_$key');
    if (cachedStr == null) return null;
    final cacheObj = json.decode(cachedStr);
    final timestamp = cacheObj['timestamp'] as int;
    if (DateTime.now().millisecondsSinceEpoch - timestamp > expiryMinutes * 60 * 1000) return null;
    return cacheObj['data'];
  }
}
