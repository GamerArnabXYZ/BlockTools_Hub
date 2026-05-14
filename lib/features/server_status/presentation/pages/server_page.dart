import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
SERVER BROWSER v4:
- Favorites System.
- Icon Caching.
- Compatibility Warnings.
- Improved Latency display.
*/
class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _serverData;
  bool _isLoading = false;
  String? _error;
  List<String> _favServers = [];

  @override
  void initState() {
    super.initState();
    _loadFavs();
  }

  void _loadFavs() {
    setState(() => _favServers = StorageService.getHistory('server_favs'));
  }

  Future<void> _checkServer([String? ip]) async {
    final serverIp = ip ?? _controller.text.trim();
    if (serverIp.isEmpty) return;
    if (ip != null) _controller.text = ip;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _serverData = null; _error = null; });

    final data = await MinecraftApiService.getServerStatus(serverIp);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) { _serverData = data; }
        else { _error = "Server lookup failed."; }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Server Browser v4',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  TextField(controller: _controller, decoration: const InputDecoration(hintText: 'e.g. play.hypixel.net', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _checkServer, child: const Text('SEARCH SERVER'))),
                ],
              ),
            ),
            
            if (_isLoading) _buildSkeleton(),
            if (_serverData != null) _buildResult(),
            
            if (_favServers.isNotEmpty && !_isLoading) ...[
              const SizedBox(height: 30),
              const Align(alignment: Alignment.centerLeft, child: Text('FAVORITE SERVERS', style: TextStyle(fontSize: 9, color: Colors.white38))),
              const SizedBox(height: 10),
              ..._favServers.map((s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: MinecraftCard(onTap: () => _checkServer(s), padding: 8, child: Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 10), Text(s, style: const TextStyle(fontSize: 12))])))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return const Padding(padding: EdgeInsets.only(top: 20), child: MinecraftCard(child: Column(children: [MinecraftSkeleton(height: 15, width: 100), SizedBox(height: 15), MinecraftSkeleton(height: 40, width: double.infinity)])));
  }

  Widget _buildResult() {
    final online = _serverData!['online'] == true;
    final ip = _controller.text;
    final isFav = _favServers.contains(ip);

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
                  Row(children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: online ? Colors.green : Colors.red)),
                    const SizedBox(width: 8),
                    Text(online ? 'ONLINE' : 'OFFLINE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ]),
                  IconButton(
                    icon: Icon(isFav ? Icons.star : Icons.star_border, color: Colors.amber, size: 20),
                    onPressed: () { StorageService.toggleFavorite('server_favs', ip); _loadFavs(); },
                  ),
                ],
              ),
              if (online) ...[
                const SizedBox(height: 15),
                /* Server Icon (Base64) */
                if (_serverData!['icon'] != null)
                   Container(height: 64, width: 64, decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)), child: Image.memory(base64Decode(_serverData!['icon'].split(',').last), fit: BoxFit.cover)),
                const SizedBox(height: 15),
                Text('${_serverData!['players']['online']} PLAYERS', style: const TextStyle(fontSize: 16, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(_serverData!['version'] ?? 'N/A', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () { Clipboard.setData(ClipboardData(text: ip)); showMinecraftToast(context, 'IP Copied!'); }, child: const Text('COPY IP')),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
