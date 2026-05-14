import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';

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

  Future<void> _checkServer() async {
    final ip = _controller.text.trim();
    if (ip.isEmpty) return;

    setState(() {
      _isLoading = true;
      _serverData = null;
      _error = null;
    });

    final data = await MinecraftApiService.getServerStatus(ip);

    setState(() {
      _isLoading = false;
      if (data != null) {
        _serverData = data;
      } else {
        _error = "Could not fetch server status. Check IP.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Server Status',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  const Text('SERVER IP (JAVA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'e.g. hypixel.net',
                      filled: true,
                      fillColor: Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkServer,
                      child: _isLoading 
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text('CHECK STATUS'),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ],
            if (_serverData != null) ...[
              const SizedBox(height: 20),
              MinecraftCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_serverData!['online'] == true) ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text((_serverData!['online'] == true) ? 'ONLINE' : 'OFFLINE', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (_serverData!['online'] == true) ...[
                      Text('PLAYERS: ${_serverData!['players']['online']} / ${_serverData!['players']['max']}',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 13)),
                      const SizedBox(height: 10),
                      Text('VERSION: ${_serverData!['version'] ?? 'N/A'}', style: const TextStyle(fontSize: 11)),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _controller.text));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('IP Copied!')));
                      },
                      child: const Text('COPY IP'),
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
