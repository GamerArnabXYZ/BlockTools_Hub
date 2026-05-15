import 'dart:convert';
import 'package:http/http.dart' as http;

/* 
API SERVICE v4.5:
- Fully Integrated mc-heads.net endpoints.
- Added Isometric, Combo, and Player render support.
- Added Skin Download and Raw Texture helpers.
*/
class MinecraftApiService {
  static const String playerDbBase = 'https://playerdb.co/api/player/minecraft';
  static const String serverBase = 'https://api.mcsrvstat.us/2';
  static const String mcHeadsBase = 'https://mc-heads.net';

  /* Player Profile fetch karna */
  static Future<Map<String, dynamic>?> getPlayerProfile(String identifier) async {
    try {
      final response = await http.get(Uri.parse('$playerDbBase/$identifier')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data']['player'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /* Server Status fetch karna */
  static Future<Map<String, dynamic>?> getServerStatus(String ip) async {
    try {
      final response = await http.get(Uri.parse('$serverBase/$ip')).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /* --- Advanced mc-heads.net Helpers --- */

  // Basic Avatar with helm/nohelm
  static String getAvatarUrl(String identifier, {int size = 100, bool noHelm = false}) {
    return '$mcHeadsBase/avatar/$identifier/$size${noHelm ? '/nohelm' : ''}.png';
  }

  // Isometric Head
  static String getHeadUrl(String identifier, {int size = 100, String direction = ''}) {
    // direction can be 'left' or 'right'
    String url = '$mcHeadsBase/head/$identifier/$size';
    if (direction.isNotEmpty) url += '/$direction';
    return url;
  }

  // Isometric Body
  static String getBodyUrl(String identifier, {int size = 250, String direction = ''}) {
    String url = '$mcHeadsBase/body/$identifier/$size';
    if (direction.isNotEmpty) url += '/$direction';
    return url;
  }

  // Full Body 3D-like Render
  static String getPlayerRenderUrl(String identifier, {int size = 250}) {
    return '$mcHeadsBase/player/$identifier/$size';
  }

  // Combo (Head + Body)
  static String getComboUrl(String identifier, {int size = 250}) {
    return '$mcHeadsBase/combo/$identifier/$size';
  }

  // Raw Skin Texture
  static String getSkinTextureUrl(String identifier) {
    return '$mcHeadsBase/skin/$identifier';
  }

  // Download Skin URL
  static String getDownloadSkinUrl(String identifier) {
    return '$mcHeadsBase/download/$identifier';
  }

  static String getCapeUrl(String uuid) {
    return '$mcHeadsBase/cape/$uuid';
  }

  // Common Cape Textures
  static const Map<String, String> commonCapes = {
    'Migrator': 'https://textures.minecraft.net/texture/2b3096abc9bc5392d476e338c3ed7095c5240a25697a548c7755b68df7e5971',
    'Minecon 2011': 'https://textures.minecraft.net/texture/95d6881cd095ea60657755970b313391d4e43fcf0964720993959e13e859781',
    'Minecon 2012': 'https://textures.minecraft.net/texture/a2e0a68393e507797e8e50f3f2d01e45300f89816222b40742f53f315a6b07d',
    'Minecon 2013': 'https://textures.minecraft.net/texture/153b1a0dfcbae953cce6f2913f56d6b5d95cf1a9660ad4e39aee1f17c6a9ebc',
    'Minecon 2015': 'https://textures.minecraft.net/texture/b05865c0ee11ca7c90cc0560a8053a47963c63102a06145ca4cb6c5c0d5079e',
    'Minecon 2016': 'https://textures.minecraft.net/texture/ba24ae3089d70238e55e0031835928e3b2024b45500e57ba541a547a469a9187',
  };
}
