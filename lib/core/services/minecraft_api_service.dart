import 'dart:convert';
import 'package:http/http.dart' as http;

/* 
DEEP FIX:
- PlayerDB.co use kiya hai kyunki ye CORS friendly hai (Web build ke liye zaroori).
- Mojang API direct web se kaam nahi karta (CORS error).
*/
class MinecraftApiService {
  // PlayerDB is great for Web + Android
  static const String playerDbBase = 'https://playerdb.co/api/player/minecraft';
  // Server Status API (CORS friendly)
  static const String serverBase = 'https://api.mcsrvstat.us/2';
  // Crafatar remains good for renders
  static const String crafatarBase = 'https://crafatar.com';

  /* PlayerDB se player data fetch karna */
  static Future<Map<String, dynamic>?> getPlayerProfile(String identifier) async {
    try {
      final response = await http.get(Uri.parse('$playerDbBase/$identifier'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Data format match karne ke liye map return kar rahe hain
          final player = data['data']['player'];
          return {
            'name': player['username'],
            'id': player['id'],
            'avatar': player['avatar'],
          };
        }
      }
      return null;
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }

  /* Server status fetch karna */
  static Future<Map<String, dynamic>?> getServerStatus(String ip) async {
    try {
      final response = await http.get(Uri.parse('$serverBase/$ip'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Server API Error: $e');
      return null;
    }
  }

  /* 2D Skin Render URL */
  static String getSkinRenderUrl(String uuid) {
    return '$crafatarBase/renders/body/$uuid?overlay=true&scale=10';
  }

  /* Avatar/Face URL (PlayerDB bhi deta hai, lekin Crafatar backup ke liye) */
  static String getAvatarUrl(String uuid) {
    return '$crafatarBase/avatars/$uuid?overlay=true';
  }
}
