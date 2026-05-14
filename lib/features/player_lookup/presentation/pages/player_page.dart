import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
PLAYER LOOKUP v4:
- Advanced Profile Dashboard.
- Cape detection UI.
- Share & Download logic.
- Expanded info sections.
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
  String? _error;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() => _history = StorageService.getHistory('player_history'));
  }

  Future<void> _searchPlayer([String? name]) async {
    final username = name ?? _controller.text.trim();
    if (username.isEmpty) return;
    if (name != null) _controller.text = name;

    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _playerData = null; _error = null; });

    final cached = StorageService.getCachedData('player_$username');
    if (cached != null) {
      setState(() { _playerData = cached; _isLoading = false; });
      return;
    }

    final data = await MinecraftApiService.getPlayerProfile(username);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) {
          _playerData = data;
          StorageService.addHistory('player_history', username);
          StorageService.cacheData('player_$username', data);
          _loadHistory();
        } else {
          _error = "Player not found.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Player Profile v4',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Enter username...', border: OutlineInputBorder()),
                    onSubmitted: (_) => _searchPlayer(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _searchPlayer, child: const Text('GET PROFILE'))),
                ],
              ),
            ),

            if (_isLoading) _buildSkeleton(),
            if (_error != null) _buildError(),
            if (_playerData != null) _buildProfileDashboard(),
            
            if (_history.isNotEmpty && !_isLoading) _buildHistoryChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return const Padding(
      padding: EdgeInsets.only(top: 20),
      child: MinecraftCard(child: Column(children: [MinecraftSkeleton(height: 20, width: 150), SizedBox(height: 10), MinecraftSkeleton(height: 100, width: 100)])),
    );
  }

  Widget _buildError() {
    return Padding(padding: const EdgeInsets.only(top: 20), child: Text(_error!, style: const TextStyle(color: Colors.redAccent)));
  }

  Widget _buildProfileDashboard() {
    final uuid = _playerData!['id'];
    final name = _playerData!['username'] ?? _playerData!['name'];
    final isFav = StorageService.isFavorite('player_favs', name);

    return Column(
      children: [
        const SizedBox(height: 20),
        MinecraftCard(
          color: const Color(0xFF1A1A1A),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name.toString().toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                    onPressed: () { StorageService.toggleFavorite('player_favs', name); setState(() {}); },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              /* Avatar & Cape Preview Row */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileBit('SKIN', Image.network(MinecraftApiService.getAvatarUrl(uuid), height: 80)),
                  _buildProfileBit('CAPE', Image.network(MinecraftApiService.getCapeUrl(uuid), height: 80, errorBuilder: (_, __, ___) => const Icon(Icons.block, size: 40, color: Colors.white24))),
                ],
              ),
              const SizedBox(height: 20),
              /* Details List */
              _buildDetailRow('UUID', uuid),
              _buildDetailRow('BADGES', 'OFFICIAL PLAYER'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: () { Clipboard.setData(ClipboardData(text: 'https://namemc.com/profile/$uuid')); showMinecraftToast(context, 'Profile Link Copied!'); }, child: const Text('SHARE'))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: () { /* Logic for skin download usually involves opening URL in browser */ }, child: const Text('DOWNLOAD SKIN'))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileBit(String label, Widget child) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(8), color: Colors.black26, child: child),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38)),
          Text(value, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistoryChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text('RECENT DISCOVERIES', style: TextStyle(fontSize: 9, color: Colors.white38)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: _history.map((h) => ActionChip(label: Text(h, style: const TextStyle(fontSize: 10)), onPressed: () => _searchPlayer(h), backgroundColor: const Color(0xFF313131), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero))).toList()),
      ],
    );
  }
}
