import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _playerData;
  bool _isLoading = false;
  String? _error;

  Future<void> _searchPlayer() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _playerData = null;
      _error = null;
    });

    final data = await MinecraftApiService.getPlayerProfile(username);

    setState(() {
      _isLoading = false;
      if (data != null) {
        _playerData = data;
      } else {
        _error = "Player not found or API error.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Player Lookup',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  const Text('MINECRAFT USERNAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Dream',
                      filled: true,
                      fillColor: Color(0xFF1A1A1A),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                    onSubmitted: (_) => _searchPlayer(),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _searchPlayer,
                      child: _isLoading 
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                        : const Text('SEARCH'),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ],
            if (_playerData != null) ...[
              const SizedBox(height: 20),
              MinecraftCard(
                child: Column(
                  children: [
                    Text(_playerData!['name'].toString().toUpperCase(), 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                    const SizedBox(height: 5),
                    Text('UUID: ${_playerData!['id']}', style: const TextStyle(fontSize: 9, color: Colors.white54)),
                    const SizedBox(height: 20),
                    /* Fixed Avatar Render using mc-heads.net */
                    Image.network(
                      MinecraftApiService.getAvatarUrl(_playerData!['id']),
                      height: 80,
                      width: 80,
                      cacheWidth: 160,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(height: 80, width: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                      },
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 80),
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
