import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';

/* 
SKIN VIEWER v4:
- Front/Back Toggle.
- Slim/Classic model detection.
- Zoom & Pan improvements.
- HD rendering.
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
  bool _showBack = false;
  Color _bgType = const Color(0xFF1E1E1E);

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
    final data = await MinecraftApiService.getPlayerProfile(username);
    setState(() {
      _isLoading = false;
      if (data != null) { _uuid = data['id']; }
      else { showMinecraftToast(context, 'Player not found!'); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Skin Explorer v4',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  TextField(controller: _controller, style: const TextStyle(fontSize: 14), decoration: const InputDecoration(hintText: 'Enter username...', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _fetchSkin, child: const Text('VIEW SKIN'))),
                ],
              ),
            ),

            if (_uuid != null) ...[
              const SizedBox(height: 20),
              /* Controls Row */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /* Side Toggle */
                  _buildToggleBtn(_showBack ? 'SHOW FRONT' : 'SHOW BACK', () => setState(() => _showBack = !_showBack)),
                  /* BG Switcher */
                  _buildBgSwitcher(),
                ],
              ),
              const SizedBox(height: 15),
              /* Render View */
              MinecraftCard(
                color: _bgType,
                padding: 0,
                child: SizedBox(
                  height: 450,
                  width: double.infinity,
                  child: InteractiveViewer(
                    child: Center(
                      child: Image.network(
                        MinecraftApiService.getSkinRenderUrl(_uuid!, back: _showBack),
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) => progress == null ? child : const CircularProgressIndicator(color: Colors.white24),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('PINCH TO ZOOM • TAP TO TOGGLE LAYER', style: TextStyle(fontSize: 8, color: Colors.white24)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String label, VoidCallback onTap) {
    return MinecraftCard(
      onTap: onTap,
      padding: 6,
      color: Colors.blueGrey.shade900,
      child: Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBgSwitcher() {
    return Row(
      children: _bgOptions.entries.map((e) => GestureDetector(
        onTap: () => setState(() => _bgType = e.value),
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          width: 20, height: 20,
          decoration: BoxDecoration(color: e.value, border: Border.all(color: _bgType == e.value ? Colors.white : Colors.black, width: 1.5)),
        ),
      )).toList(),
    );
  }
}
