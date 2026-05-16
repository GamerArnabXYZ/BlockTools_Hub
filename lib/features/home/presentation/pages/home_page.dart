import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
NATIVE DASHBOARD v7:
- Material 3 Content structure.
- Activity feed style.
- Enhanced Typography.
*/
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _searchCount = 0;
  int _favCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _searchCount = StorageService.getHistory('player_history').length + 
                     StorageService.getHistory('server_history').length;
      _favCount = StorageService.getHistory('player_favs').length + 
                  StorageService.getHistory('server_favs').length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Platform Hub',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          /* Welcome Card */
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          
          /* Analytics Section */
          _buildSectionHeader('YOUR ANALYTICS'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Activities', _searchCount.toString(), Icons.history_edu, Colors.blueAccent)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Watchlist', _favCount.toString(), Icons.star_outline, Colors.amberAccent)),
            ],
          ),
          const SizedBox(height: 24),

          /* Feature Highlights */
          _buildSectionHeader('RECOMMENDED'),
          const SizedBox(height: 12),
          _buildPromoCard('Skin Studio 4.5', 'Professional isometric renders are now active.', Icons.auto_fix_high, Colors.purpleAccent),
          _buildPromoCard('Server Intel v3', 'Java & Bedrock auto-detection support.', Icons.lan, Colors.greenAccent),
          
          const SizedBox(height: 100), // Bottom nav space
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return MinecraftCard(
      color: Colors.green.shade900.withOpacity(0.2),
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SYSTEMS ONLINE', style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          const Text('Welcome to BlockTools', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const Text('The ultimate Minecraft companion platform.', style: TextStyle(fontSize: 13, color: Colors.white54)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 2));
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return MinecraftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MinecraftCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
