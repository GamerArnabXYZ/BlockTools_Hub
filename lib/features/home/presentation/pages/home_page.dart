import 'package:flutter/material.dart';
import 'package:blocktools_hub/features/seed_tools/presentation/pages/seed_page.dart';
import 'package:blocktools_hub/features/skin_viewer/presentation/pages/skin_page.dart';
import 'package:blocktools_hub/features/command_gen/presentation/pages/command_page.dart';
import 'package:blocktools_hub/features/player_lookup/presentation/pages/player_page.dart';
import 'package:blocktools_hub/features/server_status/presentation/pages/server_page.dart';

/* Dashboard screen jo saare tools ko access karne deti hai */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLOCKTOOLS HUB'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildToolCard(
              context,
              'Seed Tools',
              Icons.terrain,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SeedPage())),
            ),
            _buildToolCard(
              context,
              'Skin Viewer',
              Icons.person,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkinPage())),
            ),
            _buildToolCard(
              context,
              'Command Gen',
              Icons.terminal,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommandPage())),
            ),
            _buildToolCard(
              context,
              'Player Lookup',
              Icons.search,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerPage())),
            ),
            _buildToolCard(
              context,
              'Server Status',
              Icons.dns,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServerPage())),
            ),
          ],
        ),
      ),
    );
  }

  /* Common widget tool cards banane ke liye */
  Widget _buildToolCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.greenAccent),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
