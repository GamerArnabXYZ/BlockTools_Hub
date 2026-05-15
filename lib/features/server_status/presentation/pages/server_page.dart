import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
SERVER BROWSER v4.6:
- mcsrvstat.us v3 Support.
- Java & Bedrock switch.
- Detailed MOTD & Icon rendering.
- Favorites system integration.
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
  bool _isBedrock = false;
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

    final data = await MinecraftApiService.getServerStatus(serverIp, bedrock: _isBedrock);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) { 
          _serverData = data;
          StorageService.addHistory('server_history', serverIp);
        } else { 
          _error = "Server lookup failed. Check IP/Edition."; 
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Global Server Browser',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /* Search Card with Edition Toggle */
            MinecraftCard(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _isBedrock ? 'Bedrock IP (e.g. play.br.net)' : 'Java IP (e.g. hypixel.net)',
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _checkServer(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEditionChip('JAVA', !_isBedrock),
                      const SizedBox(width: 10),
                      _buildEditionChip('BEDROCK', _isBedrock),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _checkServer, child: const Text('CHECK SERVER'))),
                ],
              ),
            ),
            
            if (_isLoading) _buildSkeleton(),
            if (_error != null) _buildError(),
            if (_serverData != null) _buildResultCard(),
            
            if (_favServers.isNotEmpty && !_isLoading) _buildFavList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditionChip(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _isBedrock = label == 'BEDROCK'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.greenAccent : Colors.black26,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: active ? Colors.black : Colors.white)),
      ),
    );
  }

  Widget _buildSkeleton() {
    return const Padding(padding: EdgeInsets.only(top: 20), child: MinecraftCard(child: Column(children: [MinecraftSkeleton(height: 15, width: 100), SizedBox(height: 15), MinecraftSkeleton(height: 60, width: double.infinity)])));
  }

  Widget _buildError() {
    return Padding(padding: const EdgeInsets.only(top: 20), child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 11)));
  }

  Widget _buildResultCard() {
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
                    Text(online ? 'SERVER ONLINE' : 'SERVER OFFLINE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ]),
                  IconButton(
                    icon: Icon(isFav ? Icons.star : Icons.star_border, color: Colors.amber, size: 20),
                    onPressed: () { StorageService.toggleFavorite('server_favs', ip); _loadFavs(); },
                  ),
                ],
              ),
              if (online) ...[
                const SizedBox(height: 15),
                /* Server Icon (Java only usually) */
                if (_serverData!['icon'] != null)
                   Container(height: 64, width: 64, decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)), child: Image.memory(base64Decode(_serverData!['icon'].split(',').last), fit: BoxFit.cover)),
                
                const SizedBox(height: 15),
                Text('${_serverData!['players']['online']} / ${_serverData!['players']['max']} PLAYERS', style: const TextStyle(fontSize: 15, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                
                const SizedBox(height: 15),
                /* MOTD Render */
                if (_serverData!['motd'] != null && _serverData!['motd']['clean'] != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    color: Colors.black45,
                    child: Text(_serverData!['motd']['clean'].join('\n').trim(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                  ),
                
                const SizedBox(height: 15),
                _buildInfoRow('VERSION', _serverData!['version'] ?? 'Unknown'),
                _buildInfoRow('PROTOCOL', _serverData!['protocol'] != null ? _serverData!['protocol']['version'].toString() : 'N/A'),
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: () { Clipboard.setData(ClipboardData(text: ip)); showMinecraftToast(context, 'IP Copied!'); }, child: const Text('COPY IP'))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(onPressed: () { /* Future: share link */ }, child: const Text('SHARE'))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String val) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)), Text(val, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))]));
  }

  Widget _buildFavList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text('FAVORITE SERVERS', style: TextStyle(fontSize: 8, color: Colors.white24, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        ..._favServers.map((s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: MinecraftCard(onTap: () => _checkServer(s), padding: 10, child: Row(children: [const Icon(Icons.dns, color: Colors.blueAccent, size: 14), const SizedBox(width: 12), Text(s, style: const TextStyle(fontSize: 12))])))),
      ],
    );
  }
}
