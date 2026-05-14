import 'dart:convert';
import 'package:http/http.dart' as http;

/* 
FIX:
- Skin Viewer ke liye mc-heads.net use kiya hai (CORS friendly aur fast).
- PlayerDB se player data fetch ho raha hai.
*/
class MinecraftApiService {
  static const String playerDbBase = 'https://playerdb.co/api/player/minecraft';
  static const String serverBase = 'https://api.mcsrvstat.us/2';
  // mc-heads.net is very reliable for renders on web
  static const String mcHeadsBase = 'https://mc-heads.net';

  /* Player data fetch karna */
  static Future<Map<String, dynamic>?> getPlayerProfile(String identifier) async {
    try {
      final response = await http.get(Uri.parse('$playerDbBase/$identifier'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
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
      return null;
    }
  }

  /* 2D Full Body Render URL (mc-heads.net) */
  static String getSkinRenderUrl(String uuid) {
    // mc-heads.net/body/{uuid} automatically handles dashes
    return '$mcHeadsBase/body/$uuid/250';
  }

  /* Avatar URL (mc-heads.net backup) */
  static String getAvatarUrl(String uuid) {
    return '$mcHeadsBase/avatar/$uuid/100';
  }
}
