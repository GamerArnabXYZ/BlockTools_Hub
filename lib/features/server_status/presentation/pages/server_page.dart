import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/minecraft_api_service.dart';

/* Server Status feature jo Java servers ki live info dikhata hai */
class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _serverData;
  bool _isLoading = false;

  /* Server status fetch karne ka function */
  Future<void> _checkServer() async {
    final ip = _controller.text.trim();
    if (ip.isEmpty) return;

    setState(() {
      _isLoading = true;
      _serverData = null;
    });

    final data = await MinecraftApiService.getServerStatus(ip);

    setState(() {
      _isLoading = false;
      _serverData = data;
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
                  const Text('ENTER SERVER IP (JAVA)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _controller,
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
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text('CHECK STATUS'),
                    ),
                  ),
                ],
              ),
            ),
            if (_serverData != null) ...[
              const SizedBox(height: 20),
              MinecraftCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_serverData!['online'] == true) ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text((_serverData!['online'] == true) ? 'ONLINE' : 'OFFLINE', 
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (_serverData!['online'] == true) ...[
                      Text('PLAYERS: ${_serverData!['players']['online']} / ${_serverData!['players']['max']}',
                        style: const TextStyle(color: Colors.greenAccent)),
                      const SizedBox(height: 10),
                      Text('VERSION: ${_serverData!['version'] ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 15),
                      // MOTD
                      if (_serverData!['motd'] != null && _serverData!['motd']['clean'] != null)
                        Text(
                          _serverData!['motd']['clean'].join('\n'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _controller.text));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('IP Copied!')));
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('COPY IP'),
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
