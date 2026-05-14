import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';

class SeedPage extends StatelessWidget {
  const SeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Seed Tools',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  const Text(
                    'FIND YOUR NEXT ADVENTURE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter seed or browse popular ones.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter seed here...',
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('SEARCH SEED'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildSeedItem('Village Near Spawn', '123456789'),
                  _buildSeedItem('Ocean Monument', '987654321'),
                  _buildSeedItem('Ice Spikes', '5550123'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeedItem(String name, String seed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MinecraftCard(
        color: const Color(0xFF2A2A2A),
        child: ListTile(
          title: Text(name.toUpperCase(), style: const TextStyle(fontSize: 14)),
          subtitle: Text('Seed: $seed', style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
          trailing: const Icon(Icons.copy, size: 18),
        ),
      ),
    );
  }
}
