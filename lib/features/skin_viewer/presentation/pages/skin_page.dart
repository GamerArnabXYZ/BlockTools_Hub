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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Player not found!')));
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
                  const Text('GET 2D SKIN PREVIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Notch',
                      filled: true,
                      fillColor: Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _fetchSkin,
                      child: _isLoading 
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text('VIEW SKIN'),
                    ),
                  ),
                ],
              ),
            ),
            if (_uuid != null) ...[
              const SizedBox(height: 30),
              MinecraftCard(
                child: Column(
                  children: [
                    const Text('FRONT VIEW', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    const SizedBox(height: 15),
                    /* Optimized Image Loading */
                    Image.network(
                      MinecraftApiService.getSkinRenderUrl(_uuid!),
                      height: 250,
                      cacheHeight: 500, // Memory check
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
                      },
                      errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 50),
                    ),
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
