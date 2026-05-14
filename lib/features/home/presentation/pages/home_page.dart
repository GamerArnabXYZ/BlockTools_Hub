import 'package:flutter/material.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/features/seed_tools/presentation/pages/seed_page.dart';
import 'package:blocktools_hub/features/skin_viewer/presentation/pages/skin_page.dart';
import 'package:blocktools_hub/features/command_gen/presentation/pages/command_page.dart';
import 'package:blocktools_hub/features/player_lookup/presentation/pages/player_page.dart';
import 'package:blocktools_hub/features/server_status/presentation/pages/server_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'BlockTools Hub',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                /* Stylized Header */
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.greenAccent, size: 40),
                      SizedBox(height: 10),
                      Text(
                        'Welcome, Explorer!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Manage your Minecraft world with ease.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          /* Optimized Tool Grid using Slivers */
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildTool(context, 'Seed Tools', Icons.landscape, Colors.brown, const SeedPage()),
                _buildTool(context, 'Skin Viewer', Icons.accessibility_new, Colors.blue, const SkinPage()),
                _buildTool(context, 'Command Gen', Icons.code, Colors.purple, const CommandPage()),
                _buildTool(context, 'Player Look', Icons.person_search, Colors.orange, const PlayerPage()),
                _buildTool(context, 'Server Info', Icons.dns, Colors.red, const ServerPage()),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildTool(BuildContext context, String title, IconData icon, Color accent, Widget page) {
    return MinecraftCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: accent),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
