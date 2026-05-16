import 'package:flutter/material.dart';
import 'package:blocktools_hub/features/home/presentation/pages/home_page.dart';
import 'package:blocktools_hub/features/player_lookup/presentation/pages/player_page.dart';
import 'package:blocktools_hub/features/server_status/presentation/pages/server_page.dart';
import 'package:blocktools_hub/features/skin_viewer/presentation/pages/skin_page.dart';
import 'package:blocktools_hub/features/cosmetics/presentation/pages/cosmetics_page.dart';
import 'package:blocktools_hub/features/command_gen/presentation/pages/command_page.dart';

/* 
MAIN NAVIGATION v7:
- Material 3 Navigation Bar (NavigationBar).
- State preservation with IndexedStack.
*/
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const PlayerPage(),
    const ServerPage(),
    const MoreToolsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Player'),
          NavigationDestination(icon: Icon(Icons.dns_outlined), selectedIcon: Icon(Icons.dns), label: 'Server'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Utility'),
        ],
      ),
    );
  }
}

/* 
UTILITY HUB v7:
- Native list style.
- Clean M3 UI.
*/
class MoreToolsPage extends StatelessWidget {
  const MoreToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTILITY HUB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildUtilityTile(context, 'Skin Studio Pro', 'Advanced isometric renders.', Icons.accessibility_new, const SkinPage()),
          _buildUtilityTile(context, 'Cosmetic Explorer', 'Mojang capes & cosmetics.', Icons.auto_awesome, const CosmeticsPage()),
          _buildUtilityTile(context, 'Command Studio', 'Generate and save commands.', Icons.terminal, const CommandPage()),
        ],
      ),
    );
  }

  Widget _buildUtilityTile(BuildContext context, String title, String subtitle, IconData icon, Widget page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.greenAccent, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
