import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
PLAYER LOOKUP v5.0:
- mc-api.io integration with fallback.
- Advanced Profile Dashboard.
*/
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _playerData;
  bool _isLoading = false;
  String _edition = 'java'; // Default

  Future<void> _searchPlayer() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _playerData = null; });

    final data = await MinecraftApiService.getPlayerProfile(name, _edition);
    if (mounted) {
      setState(() { _isLoading = false; _playerData = data; });
      if (data == null) showMinecraftToast(context, 'Profile not found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Global Profile Search',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Enter Username...', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'java', label: Text('JAVA')),
                      ButtonSegment(value: 'bedrock', label: Text('BEDROCK')),
                    ],
                    selected: {_edition},
                    onSelectionChanged: (val) => setState(() => _edition = val.first),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _searchPlayer, child: const Text('SEARCH'))),
                ],
              ),
            ),
            if (_isLoading) const Padding(padding: EdgeInsets.only(top: 20), child: CircularProgressIndicator()),
            if (_playerData != null) _buildProfile(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final isMcApi = _playerData!['api_source'] == 'mc-api';
    final name = _playerData!['name'] ?? 'Unknown';
    
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: MinecraftCard(
        color: const Color(0xFF1A1A1A),
        child: Column(
          children: [
            Text(name.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            const SizedBox(height: 20),
            if (isMcApi)
              Image.network(MinecraftApiService.getRenderUrl('full', name, _edition), height: 250, fit: BoxFit.contain),
            
            const SizedBox(height: 20),
            _buildRow('UUID', _playerData!['uuid'] ?? _playerData!['id']),
            if (_playerData!.containsKey('xuid')) _buildRow('XUID', _playerData!['xuid'].toString()),
            
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {
              Clipboard.setData(ClipboardData(text: 'https://mc-api.io/profile/$name/$_edition'));
              showMinecraftToast(context, 'Link Copied!');
            }, child: const Text('SHARE PROFILE')),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)), Expanded(child: Text(val, textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)))]));
  }
}
