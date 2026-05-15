import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';

/* 
SKIN EXPLORER v4.5:
- Added Render Types: Isometric, Full Player, Combo.
- Added Facing Direction: Left/Right.
- Added Skin Download integration.
- Added Texture viewer.
*/
class SkinPage extends StatefulWidget {
  const SkinPage({super.key});

  @override
  State<SkinPage> createState() => _SkinPageState();
}

class _SkinPageState extends State<SkinPage> {
  final TextEditingController _controller = TextEditingController();
  String? _uuid;
  bool _isLoading = false;
  
  // Render Settings
  String _renderType = 'Body'; // Body, Head, Player, Combo
  String _direction = 'right'; // left, right
  Color _bgType = const Color(0xFF1E1E1E);

  final List<String> _renderOptions = ['Body', 'Head', 'Player', 'Combo'];
  final Map<String, Color> _bgOptions = {
    'DARK': const Color(0xFF1E1E1E),
    'GRASS': const Color(0xFF3C8527),
    'STONE': const Color(0xFF5A5A5A),
  };

  Future<void> _fetchSkin() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _uuid = null; });
    // 'java' edition default set kiya hai
    final data = await MinecraftApiService.getPlayerProfile(username, 'java');
    setState(() {
      _isLoading = false;
      if (data != null) { _uuid = data['id']; }
      else { showMinecraftToast(context, 'Player not found!'); }
    });
  }

  String _getFinalUrl() {
    if (_uuid == null) return '';
    switch (_renderType) {
      case 'Head': return MinecraftApiService.getHeadUrl(_uuid!, direction: _direction, size: 250);
      case 'Player': return MinecraftApiService.getPlayerRenderUrl(_uuid!, size: 250);
      case 'Combo': return MinecraftApiService.getComboUrl(_uuid!, size: 250);
      default: return MinecraftApiService.getBodyUrl(_uuid!, direction: _direction, size: 250);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Skin Studio v4.5',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /* Search Card */
            MinecraftCard(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Username or UUID', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _fetchSkin, child: const Text('EXPLORE SKIN'))),
                ],
              ),
            ),

            if (_uuid != null) ...[
              const SizedBox(height: 20),
              
              /* Render Controls */
              _buildRenderControls(),
              
              const SizedBox(height: 15),
              
              /* Main Viewport */
              MinecraftCard(
                color: _bgType,
                padding: 0,
                child: SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: InteractiveViewer(
                    child: Center(
                      child: Image.network(
                        _getFinalUrl(),
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) => progress == null ? child : const CircularProgressIndicator(color: Colors.white24),
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.white10),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              /* Quick Actions */
              Row(
                children: [
                  Expanded(child: _buildActionButton('DOWNLOAD', Icons.download, () {
                     Clipboard.setData(ClipboardData(text: MinecraftApiService.getDownloadSkinUrl(_uuid!)));
                     showMinecraftToast(context, 'Download Link Copied!');
                  })),
                  const SizedBox(width: 10),
                  Expanded(child: _buildActionButton('TEXTURE', Icons.grid_on, () {
                     Clipboard.setData(ClipboardData(text: MinecraftApiService.getSkinTextureUrl(_uuid!)));
                     showMinecraftToast(context, 'Texture URL Copied!');
                  })),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRenderControls() {
    return MinecraftCard(
      color: const Color(0xFF252525),
      padding: 8,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _renderOptions.map((opt) => GestureDetector(
              onTap: () => setState(() => _renderType = opt),
              child: Text(opt.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _renderType == opt ? Colors.greenAccent : Colors.white38)),
            )).toList(),
          ),
          const Divider(color: Colors.black, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /* Direction Toggle */
              Row(
                children: ['left', 'right'].map((dir) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(dir.toUpperCase(), style: const TextStyle(fontSize: 8)),
                    backgroundColor: _direction == dir ? Colors.blueAccent : Colors.black26,
                    onPressed: () => setState(() => _direction = dir),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                )).toList(),
              ),
              /* BG Switcher */
              _buildBgSwitcher(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBgSwitcher() {
    return Row(
      children: _bgOptions.entries.map((e) => GestureDetector(
        onTap: () => setState(() => _bgType = e.value),
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          width: 16, height: 16,
          decoration: BoxDecoration(color: e.value, border: Border.all(color: _bgType == e.value ? Colors.white : Colors.black, width: 1)),
        ),
      )).toList(),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return MinecraftCard(
      onTap: onTap,
      padding: 8,
      color: Colors.blueGrey.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
