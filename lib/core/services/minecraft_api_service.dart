import 'dart:convert';
import 'package:http/http.dart' as http;

/* 
API SERVICE v5.1:
- Restored missing legacy renderers & capes to fix compilation errors.
*/
class MinecraftApiService {
  static const String mcApiBase = 'https://mc-api.io';
  static const String playerDbBase = 'https://playerdb.co/api/player/minecraft';
  static const String mcHeadsBase = 'https://mc-heads.net';
  static const String serverBase = 'https://api.mcsrvstat.us/3';
  static const String serverBedrockBase = 'https://api.mcsrvstat.us/bedrock/3';

  static Future<Map<String, dynamic>?> getPlayerProfile(String name, String edition) async {
    try {
      final response = await http.get(Uri.parse('$mcApiBase/profile/$name/$edition')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return { ...data, 'api_source': 'mc-api' };
      }
    } catch (e) {
      print('mc-api failed: $e');
    }

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
    return '$mcApiBase/render/$type/$name/$edition';
  }

  /* Legacy Fallback Renderers & Helpers restored for Phase 5.1 */
  static String getAvatarUrl(String identifier, {int size = 100}) {
    return '$mcHeadsBase/avatar/$identifier/$size.png';
  }

  static String getHeadUrl(String identifier, {int size = 100, String direction = ''}) {
    String url = '$mcHeadsBase/head/$identifier/$size';
    if (direction.isNotEmpty) url += '/$direction';
    return url;
  }

  static String getBodyUrl(String identifier, {int size = 250, String direction = ''}) {
    String url = '$mcHeadsBase/body/$identifier/$size';
    if (direction.isNotEmpty) url += '/$direction';
    return url;
  }

  static String getPlayerRenderUrl(String identifier, {int size = 250}) {
    return '$mcHeadsBase/player/$identifier/$size';
  }

  static String getComboUrl(String identifier, {int size = 250}) {
    return '$mcHeadsBase/combo/$identifier/$size';
  }

  static String getDownloadSkinUrl(String identifier) {
    return '$mcHeadsBase/download/$identifier';
  }

  static String getSkinTextureUrl(String identifier) {
    return '$mcHeadsBase/skin/$identifier';
  }

  static String getCapeUrl(String uuid) {
    return '$mcHeadsBase/cape/$uuid';
  }

  static const Map<String, String> commonCapes = {
    'Migrator': 'https://textures.minecraft.net/texture/2b3096abc9bc5392d476e338c3ed7095c5240a25697a548c7755b68df7e5971',
    'Minecon 2011': 'https://textures.minecraft.net/texture/95d6881cd095ea60657755970b313391d4e43fcf0964720993959e13e859781',
    'Minecon 2012': 'https://textures.minecraft.net/texture/a2e0a68393e507797e8e50f3f2d01e45300f89816222b40742f53f315a6b07d',
    'Minecon 2013': 'https://textures.minecraft.net/texture/153b1a0dfcbae953cce6f2913f56d6b5d95cf1a9660ad4e39aee1f17c6a9ebc',
    'Minecon 2015': 'https://textures.minecraft.net/texture/b05865c0ee11ca7c90cc0560a8053a47963c63102a06145ca4cb6c5c0d5079e',
    'Minecon 2016': 'https://textures.minecraft.net/texture/ba24ae3089d70238e55e0031835928e3b2024b45500e57ba541a547a469a9187',
  };

  static String getSkinRenderUrl(String uuid, {bool back = false}) {
    return '$mcHeadsBase/${back ? 'back' : 'body'}/$uuid/250';
  }
}
