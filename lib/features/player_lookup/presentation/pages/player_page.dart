import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
PLAYER LOOKUP v2:
- History & Favorites support.
- API Caching.
- Skeleton loading.
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
    setState(() {
      _history = StorageService.getHistory('player_history');
    });
  }

  Future<void> _searchPlayer([String? name]) async {
    final username = name ?? _controller.text.trim();
    if (username.isEmpty) return;
    if (name != null) _controller.text = name;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _playerData = null;
      _error = null;
    });

    // Try Cache first
    final cached = StorageService.getCachedData('player_$username');
    if (cached != null) {
      setState(() {
        _playerData = cached;
        _isLoading = false;
      });
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
      title: 'Player Lookup v2',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    onSubmitted: (_) => _searchPlayer(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _searchPlayer,
                      child: const Text('SEARCH PLAYER'),
                    ),
                  ),
                ],
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 20),
              const MinecraftCard(
                child: Column(
                  children: [
                    MinecraftSkeleton(height: 20, width: 150),
                    SizedBox(height: 10),
                    MinecraftSkeleton(height: 10, width: 200),
                    SizedBox(height: 20),
                    MinecraftSkeleton(height: 80, width: 80),
                  ],
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 20),
              Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
            ],

            if (_playerData != null) ...[
              const SizedBox(height: 20),
              _buildResultCard(),
            ],

            if (_history.isNotEmpty && !_isLoading) ...[
              const SizedBox(height: 30),
              const Text('RECENT SEARCHES', style: TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _history.map((h) => ActionChip(
                  label: Text(h, style: const TextStyle(fontSize: 10)),
                  backgroundColor: const Color(0xFF313131),
                  onPressed: () => _searchPlayer(h),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final uuid = _playerData!['id'];
    final name = _playerData!['name'];
    final isFav = StorageService.isFavorite('player_favs', name);

    return MinecraftCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name.toString().toUpperCase(), 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                onPressed: () {
                  StorageService.toggleFavorite('player_favs', name);
                  setState(() {});
                  showMinecraftToast(context, isFav ? 'Removed from favorites' : 'Added to favorites');
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text('UUID: $uuid', style: const TextStyle(fontSize: 9, color: Colors.white38)),
          const SizedBox(height: 20),
          Image.network(
            MinecraftApiService.getAvatarUrl(uuid),
            height: 100,
            width: 100,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
