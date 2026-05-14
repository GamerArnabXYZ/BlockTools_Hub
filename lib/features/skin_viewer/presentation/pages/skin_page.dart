import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';

/* 
SKIN VIEWER v2:
- Background selector.
- Zoom & Pan support.
- Fallback logic.
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
  Color _bgType = const Color(0xFF1E1E1E); // Default dark

  final Map<String, Color> _bgOptions = {
    'DARK': const Color(0xFF1E1E1E),
    'GRASS': const Color(0xFF3C8527),
    'STONE': const Color(0xFF5A5A5A),
  };

  Future<void> _fetchSkin() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _uuid = null;
    });

    final data = await MinecraftApiService.getPlayerProfile(username);

    setState(() {
      _isLoading = false;
      if (data != null) {
        _uuid = data['id'];
      } else {
        showMinecraftToast(context, 'Player not found!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Skin Viewer v2',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /* Search Input */
            MinecraftCard(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Enter username...',
                      filled: true,
                      fillColor: Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                    onSubmitted: (_) => _fetchSkin(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _fetchSkin,
                      child: const Text('VIEW SKIN'),
                    ),
                  ),
                ],
              ),
            ),

            if (_uuid != null) ...[
              const SizedBox(height: 20),
              
              /* Background Selector */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _bgOptions.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    label: Text(e.key, style: const TextStyle(fontSize: 9)),
                    backgroundColor: _bgType == e.value ? Colors.blueAccent : const Color(0xFF313131),
                    onPressed: () => setState(() => _bgType = e.value),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                )).toList(),
              ),

              const SizedBox(height: 10),

              /* Render Display */
              MinecraftCard(
                color: _bgType,
                padding: 0,
                child: SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: Center(
                      child: Image.network(
                        MinecraftApiService.getSkinRenderUrl(_uuid!),
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const CircularProgressIndicator(color: Colors.white);
                        },
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('PINCH TO ZOOM • DRAG TO PAN', style: TextStyle(fontSize: 8, color: Colors.white24)),
            ],
          ],
        ),
      ),
    );
  }
}
