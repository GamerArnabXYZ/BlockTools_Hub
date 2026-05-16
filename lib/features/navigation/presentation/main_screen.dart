import 'package:flutter/material.dart';
import 'package:blocktools_hub/features/home/presentation/pages/home_page.dart';
import 'package:blocktools_hub/features/player_lookup/presentation/pages/player_page.dart';
import 'package:blocktools_hub/features/server_status/presentation/pages/server_page.dart';
import 'package:blocktools_hub/features/skin_viewer/presentation/pages/skin_page.dart';
import 'package:blocktools_hub/features/cosmetics/presentation/pages/cosmetics_page.dart';
import 'package:blocktools_hub/features/command_gen/presentation/pages/command_page.dart';

/* 
MAIN SCREEN v6:
- Native Bottom Navigation Bar.
- IndexedStack to preserve state.
- Floating design for "Cool" app feel.
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
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          border: Border.all(color: Colors.white10, width: 1),
          borderRadius: BorderRadius.circular(16), // Rounded for "App" feel
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.white30,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Player'),
            BottomNavigationBarItem(icon: Icon(Icons.dns_outlined), activeIcon: Icon(Icons.dns), label: 'Server'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'More'),
          ],
        ),
      ),
    );
  }
}

/* More tools list page */
class MoreToolsPage extends StatelessWidget {
  const MoreToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ALL UTILITIES')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMoreItem(context, 'Skin Studio', Icons.accessibility_new, const SkinPage()),
          _buildMoreItem(context, 'Cosmetics', Icons.auto_awesome, const CosmeticsPage()),
          _buildMoreItem(context, 'Command Studio', Icons.terminal, const CommandPage()),
        ],
      ),
    );
  }

  Widget _buildMoreItem(BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1A1A),
      child: ListTile(
        leading: Icon(icon, color: Colors.greenAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.white24),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
