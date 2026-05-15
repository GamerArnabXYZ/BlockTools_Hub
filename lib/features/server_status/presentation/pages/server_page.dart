import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
SERVER BROWSER v4.8:
- Auto-Detection Logic: Java aur Bedrock dono ko parallel check karta hai.
- Toggle hata diya gaya hai taaki user experience seamless ho.
- Agar server cross-play support karta hai, toh dono results stack honge.
*/
class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  final TextEditingController _controller = TextEditingController();
  
  Map<String, dynamic>? _javaData;
  Map<String, dynamic>? _bedrockData;
  
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
    setState(() { 
      _isLoading = true; 
      _javaData = null; 
      _bedrockData = null; 
      _error = null; 
    });

    // Parallel calls for speed
    try {
      final results = await Future.wait([
        MinecraftApiService.getServerStatus(serverIp, bedrock: false),
        MinecraftApiService.getServerStatus(serverIp, bedrock: true),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _javaData = results[0];
          _bedrockData = results[1];

          // Check if at least one is "online" effectively
          bool anyOnline = (_javaData != null && _javaData!['online'] == true) || 
                           (_bedrockData != null && _bedrockData!['online'] == true);

          if (anyOnline) {
            StorageService.addHistory('server_history', serverIp);
          } else if (_javaData == null && _bedrockData == null) {
            _error = "Server lookup failed. Check IP.";
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = "Network Error."; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Edition Auto-Detect',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter server IP...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _checkServer(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, 
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkServer, 
                      child: const Text('DETECT & SCAN')
                    )
                  ),
                ],
              ),
            ),
            
            if (_isLoading) _buildSkeleton(),
            if (_error != null) _buildError(),
            
            /* Results Logic */
            if (_javaData != null && _javaData!['online'] == true) 
              _buildResultCard(_javaData!, 'JAVA EDITION', Colors.blueAccent),
            
            if (_bedrockData != null && _bedrockData!['online'] == true) 
              _buildResultCard(_bedrockData!, 'BEDROCK EDITION', Colors.greenAccent),
            
            // Offline Fallback (Donon offline hain tabhi dikhayenge)
            if (!_isLoading && _javaData != null && _javaData!['online'] == false && 
                _bedrockData != null && _bedrockData!['online'] == false)
              _buildOfflineCard(),

            if (_favServers.isNotEmpty && !_isLoading) _buildFavList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> data, String edition, Color accent) {
    final ip = _controller.text;
    final isFav = _favServers.contains(ip);
    final isBedrock = edition.contains('BEDROCK');

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: MinecraftCard(
        color: const Color(0xFF1A1A1A),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                  const SizedBox(width: 8),
                  Text(edition, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: accent)),
                ]),
                IconButton(
                  icon: Icon(isFav ? Icons.star : Icons.star_border, color: Colors.amber, size: 20),
                  onPressed: () { StorageService.toggleFavorite('server_favs', ip); _loadFavs(); },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                if (data['icon'] != null)
                   Container(height: 40, width: 40, margin: const EdgeInsets.only(right: 15), decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)), child: Image.memory(base64Decode(data['icon'].split(',').last), fit: BoxFit.cover)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['players']['online']} / ${data['players']['max']} PLAYERS', style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('VERSION: ${data['version'] ?? 'N/A'}', style: const TextStyle(fontSize: 9, color: Colors.white38)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            /* MOTD */
            if (data['motd'] != null && data['motd']['clean'] != null)
              Container(width: double.infinity, padding: const EdgeInsets.all(8), color: Colors.black45, child: Text(data['motd']['clean'].join('\n').trim(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Colors.white70))),
            
            const SizedBox(height: 15),
            _buildInfoRow('PORT', data['port'].toString()),
            _buildInfoRow('SOFTWARE', data['software'] ?? 'Unknown'),
            if (isBedrock) ...[
              _buildInfoRow('MAP', data['map']?['clean'] ?? 'N/A'),
              _buildInfoRow('GAMEMODE', data['gamemode'] ?? 'N/A'),
            ],
            const SizedBox(height: 15),
            ElevatedButton(onPressed: () { Clipboard.setData(ClipboardData(text: ip)); showMinecraftToast(context, 'IP Copied!'); }, child: const Text('COPY IP')),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: MinecraftCard(
        color: const Color(0xFF2A1A1A),
        child: const Center(child: Text('SERVER IS COMPLETELY OFFLINE', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildInfoRow(String label, String val) {
    return Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)), Text(val, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold))]));
  }

  Widget _buildSkeleton() {
    return const Padding(padding: EdgeInsets.only(top: 20), child: MinecraftCard(child: Column(children: [MinecraftSkeleton(height: 15, width: 100), SizedBox(height: 15), MinecraftSkeleton(height: 60, width: double.infinity)])));
  }

  Widget _buildError() {
    return Padding(padding: const EdgeInsets.only(top: 20), child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 11)));
  }

  Widget _buildFavList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text('FAVORITE SERVERS', style: TextStyle(fontSize: 8, color: Colors.white24, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        ..._favServers.map((s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: MinecraftCard(onTap: () => _checkServer(s), padding: 10, child: Row(children: [const Icon(Icons.dns, color: Colors.blueAccent, size: 12), const SizedBox(width: 10), Text(s, style: const TextStyle(fontSize: 10))])))),
      ],
    );
  }
}
