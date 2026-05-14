import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
COSMETIC EXPLORER v4:
- Cape lists and previews.
- Favorites system for capes.
- Simple 2D cape rendering.
*/
class CosmeticsPage extends StatefulWidget {
  const CosmeticsPage({super.key});

  @override
  State<CosmeticsPage> createState() => _CosmeticsPageState();
}

class _CosmeticsPageState extends State<CosmeticsPage> {
  final List<String> _capeNames = MinecraftApiService.commonCapes.keys.toList();

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Cosmetic Explorer',
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _capeNames.length,
        itemBuilder: (context, index) {
          final name = _capeNames[index];
          final url = MinecraftApiService.commonCapes[name]!;
          final isFav = StorageService.isFavorite('fav_capes', name);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MinecraftCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      IconButton(
                        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 20),
                        onPressed: () {
                          StorageService.toggleFavorite('fav_capes', name);
                          setState(() {});
                          showMinecraftToast(context, isFav ? 'Removed from favorites' : 'Added to favorites');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Cape Texture Preview (Scaled)
                  Container(
                    height: 120,
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                        alignment: Alignment.topLeft, // Just show the front part
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('OFFICIAL MOJANG CAPE', style: TextStyle(fontSize: 8, color: Colors.white38)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
