import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';

/* Player Lookup feature jo Mojang API se UUID aur Skin fetch karta hai */
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

  /* Username se search karne ka logic */
  Future<void> _searchPlayer() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;

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
                  const Text('ENTER MINECRAFT USERNAME', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Dream',
                      filled: true,
                      fillColor: Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _searchPlayer,
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text('SEARCH'),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            if (_playerData != null) ...[
              const SizedBox(height: 20),
              MinecraftCard(
                child: Column(
                  children: [
                    Text(_playerData!['name'].toString().toUpperCase(), 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                    const SizedBox(height: 10),
                    Text('UUID: ${_playerData!['id']}', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                    const SizedBox(height: 20),
                    /* Player Avatar Preview */
                    Image.network(
                      MinecraftApiService.getAvatarUrl(_playerData!['id']),
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 100),
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
