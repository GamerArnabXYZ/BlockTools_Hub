import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
SERVER BROWSER v4.9:
- Comprehensive Intel Restoration: Added back all technical fields.
- Deep JSON parsing for DNS/SRV and Software info.
- Dynamic layout for Dual-Edition detection.
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

          bool anyOnline = (_javaData != null && _javaData!['online'] == true) || 
                           (_bedrockData != null && _bedrockData!['online'] == true);

          if (anyOnline) {
            StorageService.addHistory('server_history', serverIp);
          } else if (_javaData == null && _bedrockData == null) {
            _error = "Server lookup failed.";
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
            
            /* Java Result */
            if (_javaData != null && _javaData!['online'] == true) 
              _buildDetailedResult(_javaData!, 'JAVA EDITION', Colors.blueAccent),
            
            /* Bedrock Result */
            if (_bedrockData != null && _bedrockData!['online'] == true) 
              _buildDetailedResult(_bedrockData!, 'BEDROCK EDITION', Colors.greenAccent),
            
            if (!_isLoading && _javaData != null && _javaData!['online'] == false && 
                _bedrockData != null && _bedrockData!['online'] == false)
              _buildOfflineCard(),

            if (_favServers.isNotEmpty && !_isLoading) _buildFavList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedResult(Map<String, dynamic> data, String edition, Color accent) {
    final ip = _controller.text;
    final isFav = _favServers.contains(ip);
    final isBedrock = edition.contains('BEDROCK');

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: MinecraftCard(
        color: const Color(0xFF1A1A1A),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Header */
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
            
            const SizedBox(height: 10),
            /* Main Info Row */
            Row(
              children: [
                if (data['icon'] != null)
                   Container(height: 50, width: 50, margin: const EdgeInsets.only(right: 15), decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)), child: Image.memory(base64Decode(data['icon'].split(',').last), fit: BoxFit.cover)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['players']['online']} / ${data['players']['max']} PLAYERS', style: const TextStyle(fontSize: 15, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      Text(data['version'] ?? 'N/A', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            /* MOTD */
            if (data['motd'] != null && data['motd']['clean'] != null)
              Container(width: double.infinity, padding: const EdgeInsets.all(10), color: Colors.black45, child: Text(data['motd']['clean'].join('\n').trim(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.white70))),
            
            const SizedBox(height: 20),
            
            /* TECHNICAL SPECS SECTION */
            _buildSectionTitle('TECHNICAL SPECS'),
            _buildInfoRow('SOFTWARE', data['software'] ?? 'Vanilla/Unknown'),
            _buildInfoRow('PROTOCOL', data['protocol'] != null ? '${data['protocol']['version']} (${data['protocol']['name'] ?? ''})' : 'N/A'),
            if (isBedrock) ...[
              _buildInfoRow('MAP', data['map']?['clean'] ?? 'N/A'),
              _buildInfoRow('GAMEMODE', data['gamemode'] ?? 'N/A'),
            ],
            if (!isBedrock) _buildInfoRow('EULA BLOCKED', data['eula_blocked'] == true ? 'YES' : 'NO'),

            const SizedBox(height: 15),

            /* NETWORK INTEL SECTION */
            _buildSectionTitle('NETWORK INTEL'),
            _buildInfoRow('NUMERIC IP', data['ip'] ?? 'N/A'),
            _buildInfoRow('PORT', data['port'].toString()),
            _buildInfoRow('HOSTNAME', data['hostname'] ?? 'N/A'),
            
            /* SRV / DNS Details from Debug */
            if (data['debug']?['dns']?['srv'] != null && data['debug']['dns']['srv'].isNotEmpty)
               _buildInfoRow('SRV TARGET', data['debug']['dns']['srv'][0]['target'] ?? 'N/A'),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () { Clipboard.setData(ClipboardData(text: ip)); showMinecraftToast(context, 'Address Copied!'); }, child: const Text('COPY ADDRESS'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: () { /* Logic for full JSON export or Share */ }, child: const Text('SHARE INTEL'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(fontSize: 8, color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)));
  }

  Widget _buildInfoRow(String label, String val) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)), Expanded(child: Text(val, textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]));
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

  Widget _buildSkeleton() {
    return const Padding(padding: EdgeInsets.only(top: 20), child: MinecraftCard(child: Column(children: [MinecraftSkeleton(height: 15, width: 100), SizedBox(height: 15), MinecraftSkeleton(height: 80, width: double.infinity)])));
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
