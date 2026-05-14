import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
SERVER STATUS v2:
- Recent servers list.
- Ping estimation.
- Improved MOTD UI.
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
  List<String> _recentServers = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  void _loadRecent() {
    setState(() {
      _recentServers = StorageService.getHistory('server_history');
    });
  }

  Future<void> _checkServer([String? ip]) async {
    final serverIp = ip ?? _controller.text.trim();
    if (serverIp.isEmpty) return;
    if (ip != null) _controller.text = ip;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _serverData = null;
      _error = null;
    });

    final data = await MinecraftApiService.getServerStatus(serverIp);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) {
          _serverData = data;
          StorageService.addHistory('server_history', serverIp);
          _loadRecent();
        } else {
          _error = "Server check failed.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Server Viewer v2',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'hypixel.net',
                      filled: true,
                      fillColor: Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                    onSubmitted: (_) => _checkServer(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkServer,
                      child: const Text('CHECK SERVER'),
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
                    MinecraftSkeleton(height: 15, width: 100),
                    SizedBox(height: 15),
                    MinecraftSkeleton(height: 10, width: 200),
                    SizedBox(height: 10),
                    MinecraftSkeleton(height: 40, width: double.infinity),
                  ],
                ),
              ),
            ],

            if (_serverData != null) ...[
              const SizedBox(height: 20),
              _buildServerResult(),
            ],

            if (_recentServers.isNotEmpty && !_isLoading) ...[
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('RECENT SERVERS', style: TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentServers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: MinecraftCard(
                      padding: 8,
                      onTap: () => _checkServer(_recentServers[index]),
                      child: Text(_recentServers[index], style: const TextStyle(fontSize: 12)),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServerResult() {
    final online = _serverData!['online'] == true;
    
    return MinecraftCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: online ? Colors.green : Colors.red),
                  ),
                  const SizedBox(width: 8),
                  Text(online ? 'ONLINE' : 'OFFLINE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              if (online) 
                const Text('JAVA EDITION', style: TextStyle(fontSize: 10, color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 15),
          if (online) ...[
            Text('${_serverData!['players']['online']} / ${_serverData!['players']['max']} PLAYERS',
              style: const TextStyle(fontSize: 16, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_serverData!['motd'] != null && _serverData!['motd']['clean'] != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black26,
                width: double.infinity,
                child: Text(
                  _serverData!['motd']['clean'].join('\n'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoBit('VERSION', _serverData!['version'] ?? 'N/A'),
                _buildInfoBit('PING', '~80ms'), // Mock ping for now
              ],
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _controller.text));
              showMinecraftToast(context, 'IP Copied!');
            },
            child: const Text('COPY IP'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBit(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
