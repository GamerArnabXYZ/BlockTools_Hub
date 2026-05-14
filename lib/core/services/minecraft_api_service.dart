import 'dart:convert';
import 'package:http/http.dart' as http;

/* 
Ye service Minecraft APIs (Mojang, MC Server Status) se data fetch karti hai.
Lightweight aur error handling ke saath banayi gayi hai.
*/
class MinecraftApiService {
  // Mojang API base
  static const String mojangBase = 'https://api.mojang.com/users/profiles/minecraft';
  // Server Status API base
  static const String serverBase = 'https://api.mcsrvstat.us/2';
  // Crafatar for Renders
  static const String crafatarBase = 'https://crafatar.com';

  /* Username se UUID fetch karne ke liye */
  static Future<Map<String, dynamic>?> getPlayerProfile(String username) async {
    try {
      final response = await http.get(Uri.parse('$mojangBase/$username'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /* Server IP se status fetch karne ke liye (Java Edition) */
  static Future<Map<String, dynamic>?> getServerStatus(String ip) async {
    try {
      final response = await http.get(Uri.parse('$serverBase/$ip'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /* 2D Skin Render URL generator */
  static String getSkinRenderUrl(String uuid) {
    return '$crafatarBase/renders/body/$uuid?overlay=true&scale=10';
  }

  /* Avatar/Face URL generator */
  static String getAvatarUrl(String uuid) {
    return '$crafatarBase/avatars/$uuid?overlay=true';
  }
}
