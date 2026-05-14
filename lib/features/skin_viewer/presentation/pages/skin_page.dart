import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';

class SkinPage extends StatefulWidget {
  const SkinPage({super.key});

  @override
  State<SkinPage> createState() => _SkinPageState();
}

class _SkinPageState extends State<SkinPage> {
  final TextEditingController _controller = TextEditingController();
  String? _uuid;
  bool _isLoading = false;

  Future<void> _fetchSkin() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;

    // Hide keyboard
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player not found! Check spelling.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Skin Viewer',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  const Text('VIEW PLAYER SKIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Enter username (e.g. Notch)',
                      filled: true,
                      fillColor: Color(0xFF1A1A1A),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                    onSubmitted: (_) => _fetchSkin(),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _fetchSkin,
                      child: _isLoading 
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                        : const Text('VIEW SKIN'),
                    ),
                  ),
                ],
              ),
            ),
            if (_uuid != null) ...[
              const SizedBox(height: 25),
              MinecraftCard(
                child: Column(
                  children: [
                    const Text('2D FULL BODY PREVIEW', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    const SizedBox(height: 20),
                    /* Fixed Skin Render using mc-heads.net */
                    Image.network(
                      MinecraftApiService.getSkinRenderUrl(_uuid!),
                      height: 300,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 300,
                          child: Center(child: CircularProgressIndicator(color: Colors.green)),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Column(
                        children: [
                          Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                          SizedBox(height: 10),
                          Text('Failed to load skin render', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text('UUID: $_uuid', style: const TextStyle(fontSize: 8, color: Colors.white24)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
