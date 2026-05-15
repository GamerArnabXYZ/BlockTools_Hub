import 'dart:convert';
import 'package:http/http.dart' as http;

/* 
API SERVICE v4.6:
- Fully Integrated mcsrvstat.us v3.
- Added Bedrock Edition server support.
- Improved Mc-Heads integration.
*/
class MinecraftApiService {
  static const String playerDbBase = 'https://playerdb.co/api/player/minecraft';
  static const String mcHeadsBase = 'https://mc-heads.net';
  
  // mcsrvstat.us v3 Endpoints
  static const String serverJavaBase = 'https://api.mcsrvstat.us/3';
  static const String serverBedrockBase = 'https://api.mcsrvstat.us/bedrock/3';

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

  /* Server Status fetch karna (v3) */
  static Future<Map<String, dynamic>?> getServerStatus(String ip, {bool bedrock = false}) async {
    try {
      final String baseUrl = bedrock ? serverBedrockBase : serverJavaBase;
      final response = await http.get(Uri.parse('$baseUrl/$ip')).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /* --- mc-heads.net Helpers --- */

  static String getAvatarUrl(String identifier, {int size = 100, bool noHelm = false}) {
    return '$mcHeadsBase/avatar/$identifier/$size${noHelm ? '/nohelm' : ''}.png';
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
}
