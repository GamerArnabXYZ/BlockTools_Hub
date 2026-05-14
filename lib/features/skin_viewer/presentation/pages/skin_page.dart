import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';

/* 2D Skin Viewer jo username se 2D body render fetch karta hai */
class SkinPage extends StatefulWidget {
  const SkinPage({super.key});

  @override
  State<SkinPage> createState() => _SkinPageState();
}

class _SkinPageState extends State<SkinPage> {
  final TextEditingController _controller = TextEditingController();
  String? _uuid;
  bool _isLoading = false;

  /* Username se UUID fetch karke render URL banana */
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
                  const Text('GET 2D SKIN PREVIEW', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _controller,
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
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
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
                    const SizedBox(height: 20),
                    /* 2D Render using Crafatar */
                    Image.network(
                      MinecraftApiService.getSkinRenderUrl(_uuid!),
                      height: 300,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 50),
                    ),
                    const SizedBox(height: 20),
                    const Text('Skin fetched via Crafatar', style: TextStyle(fontSize: 9, color: Colors.white38)),
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
