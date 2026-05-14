import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';
import 'package:blocktools_hub/features/skin_viewer/presentation/pages/skin_page.dart';
import 'package:blocktools_hub/features/command_gen/presentation/pages/command_page.dart';
import 'package:blocktools_hub/features/player_lookup/presentation/pages/player_page.dart';
import 'package:blocktools_hub/features/server_status/presentation/pages/server_page.dart';
import 'package:blocktools_hub/features/cosmetics/presentation/pages/cosmetics_page.dart';

/* 
DASHBOARD v4 REDESIGN:
- Modern Companion Platform layout.
- Quick Actions panel.
- Backup/Export system.
- Favorites shortcut.
*/
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _searchCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _searchCount = StorageService.getHistory('player_history').length + 
                     StorageService.getHistory('server_history').length;
    });
  }

  void _handleBackup() {
    final json = StorageService.exportBackup();
    Clipboard.setData(ClipboardData(text: json));
    showMinecraftToast(context, 'Backup JSON Copied to Clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'BlockTools Platform',
      actions: [
        IconButton(
          icon: const Icon(Icons.backup, size: 20),
          onPressed: _handleBackup,
          tooltip: 'Export Backup',
        ),
      ],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                /* Status Banner */
                _buildStatusBanner(),
                const SizedBox(height: 25),
                /* Quick Actions */
                _buildSectionHeader('QUICK ACTIONS'),
                _buildQuickActions(),
                const SizedBox(height: 25),
                /* Main Tools */
                _buildSectionHeader('MAIN UTILITIES'),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildTool(context, 'Player Look', Icons.person_search, const Color(0xFFFF9800), const PlayerPage()),
                _buildTool(context, 'Server Info', Icons.dns, const Color(0xFFF44336), const ServerPage()),
                _buildTool(context, 'Skin Viewer', Icons.accessibility_new, const Color(0xFF2196F3), const SkinPage()),
                _buildTool(context, 'Cosmetics', Icons.auto_awesome, const Color(0xFFFFEB3B), const CosmeticsPage()),
                _buildTool(context, 'Command Studio', Icons.terminal, const Color(0xFF9C27B0), const CommandPage()),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF142414),
        border: Border.all(color: const Color(0xFF3C8527), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.grid_view, color: Colors.greenAccent, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PLATFORM STATUS: ACTIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('$_searchCount DATA POINTS SYNCED', style: const TextStyle(fontSize: 9, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildActionBtn('FAV PLAYERS', Icons.favorite, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerPage())))),
          const SizedBox(width: 10),
          Expanded(child: _buildActionBtn('SAVED CMDS', Icons.bookmark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommandPage())))),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, VoidCallback onTap) {
    return MinecraftCard(
      onTap: onTap,
      padding: 10,
      color: const Color(0xFF252525),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTool(BuildContext context, String title, IconData icon, Color accent, Widget page) {
    return MinecraftCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) => _loadStats()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: accent),
          const SizedBox(height: 12),
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
