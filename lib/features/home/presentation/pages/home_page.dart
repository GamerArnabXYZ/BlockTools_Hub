import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
DASHBOARD v6:
- Redesigned for "Mobile App" feel.
- Modern layout with animated sections.
- Quick summary cards.
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
      title: 'Dashboard',
      body: CustomScrollView(
        slivers: [
          /* Header Banner */
          SliverToBoxAdapter(
            child: Container(
              height: 180,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('HELLO, EXPLORER', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const Text('BlockTools Hub is ready.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          ),

          /* Stats Grid */
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('ACTIVITIES', _searchCount.toString(), Icons.history, Colors.blue),
                _buildStatCard('FAVORITES', _favCount.toString(), Icons.favorite, Colors.red),
              ],
            ),
          ),

          /* News/Updates Section (Mock) */
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PLATFORM UPDATES', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  _buildUpdateItem('v6.0: Native Mobile Overhaul', 'New bottom navigation and animated dashboard.'),
                  _buildUpdateItem('v5.1: API Performance Fix', 'Optimized mc-api.io integration with fallback.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return MinecraftCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)),
        ],
      ),
    ).animate().scale(delay: 200.ms);
  }

  Widget _buildUpdateItem(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 10, color: Colors.white60)),
        ],
      ),
    );
  }
}
