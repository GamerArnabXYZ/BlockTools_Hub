import 'dart:convert';
import 'package:http/http.dart' as http;

/* 
API SERVICE v5.0:
- Integrated mc-api.io for rich profile data & renders.
- Robust Fallback logic (Primary: mc-api.io -> Fallback: PlayerDB/mc-heads.net).
*/
class MinecraftApiService {
  static const String mcApiBase = 'https://mc-api.io';
  static const String playerDbBase = 'https://playerdb.co/api/player/minecraft';
  static const String mcHeadsBase = 'https://mc-heads.net';
  static const String serverBase = 'https://api.mcsrvstat.us/3';
  static const String serverBedrockBase = 'https://api.mcsrvstat.us/bedrock/3';

  /* 
  Advanced Profile Lookup with Fallback.
  - edition: 'java' or 'bedrock'
  */
  static Future<Map<String, dynamic>?> getPlayerProfile(String name, String edition) async {
    try {
      // 1. Primary: mc-api.io
      final response = await http.get(Uri.parse('$mcApiBase/profile/$name/$edition')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return { ...data, 'api_source': 'mc-api' };
      }
    } catch (e) {
      print('mc-api failed: $e');
    }

    // 2. Fallback: PlayerDB
    try {
      final response = await http.get(Uri.parse('$playerDbBase/$name')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final player = data['data']['player'];
          return {
            'name': player['username'],
            'uuid': player['id'],
            'api_source': 'playerdb'
          };
        }
      }
    } catch (e) {
      print('Fallback failed: $e');
    }
    return null;
  }

  /* Server Status fetch (v3) */
  static Future<Map<String, dynamic>?> getServerStatus(String ip, {bool bedrock = false}) async {
    try {
      final String baseUrl = bedrock ? serverBedrockBase : serverBase;
      final response = await http.get(Uri.parse('$baseUrl/$ip')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) { return null; }
    return null;
  }

  /* Render Helpers (mc-api.io) */
  static String getRenderUrl(String type, String name, String edition) {
    // type: full, face, bust
    return '$mcApiBase/render/$type/$name/$edition';
  }

  /* Legacy Fallback Renderers */
  static String getSkinRenderUrl(String uuid, {bool back = false}) {
    return '$mcHeadsBase/${back ? 'back' : 'body'}/$uuid/250';
  }
}
