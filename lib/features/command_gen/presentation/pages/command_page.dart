import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';

/* 
COMMAND STUDIO v4:
- Saved Commands List.
- Search/Filter system.
- One-click copy & share.
- Category-based presets.
*/
class CommandPage extends StatefulWidget {
  const CommandPage({super.key});

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  String _selectedCategory = 'Give Item';
  final TextEditingController _targetController = TextEditingController(text: '@p');
  final TextEditingController _itemController = TextEditingController(text: 'diamond');
  final TextEditingController _countController = TextEditingController(text: '64');
  final TextEditingController _searchController = TextEditingController();
  String _generatedCommand = '';
  Map<String, String> _savedCommands = {};

  final Map<String, List<String>> _presets = {
    'Give Item': ['diamond', 'netherite_ingot', 'golden_apple', 'elytra'],
    'Teleport': ['@p', '@a', '@r', '@e'],
    'Summon': ['zombie', 'creeper', 'ender_dragon', 'tnt'],
    'Effect': ['speed', 'strength', 'regeneration', 'night_vision'],
  };

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() {
    setState(() => _savedCommands = StorageService.getSavedCommands());
  }

  void _generate() {
    String cmd = '';
    final target = _targetController.text.trim();
    final item = _itemController.text.trim();
    switch (_selectedCategory) {
      case 'Give Item': cmd = '/give $target minecraft:$item ${_countController.text.trim()}'; break;
      case 'Teleport': cmd = '/tp $target ~ ~ ~'; break;
      case 'Summon': cmd = '/summon minecraft:$item ~ ~ ~'; break;
      case 'Effect': cmd = '/effect give $target minecraft:$item 30 1'; break;
    }
    setState(() { _generatedCommand = cmd; });
  }

  void _saveCurrent() {
    if (_generatedCommand.isEmpty) return;
    String name = 'Cmd ${DateTime.now().millisecond}';
    StorageService.saveCommand(name, _generatedCommand);
    _loadSaved();
    showMinecraftToast(context, 'Command Saved!');
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Command Studio v4',
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Colors.greenAccent,
              tabs: [Tab(text: 'BUILDER'), Tab(text: 'SAVED')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBuilderTab(),
                  _buildSavedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuilderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MinecraftCard(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF313131),
                  items: _presets.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() { _selectedCategory = val!; _itemController.text = _presets[val]!.first; }),
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextField(controller: _targetController, decoration: const InputDecoration(labelText: 'Target', border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(controller: _itemController, decoration: const InputDecoration(labelText: 'ID / Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                /* Presets */
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _presets[_selectedCategory]!.map((p) => Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(label: Text(p, style: const TextStyle(fontSize: 9)), onPressed: () => setState(() => _itemController.text = p), backgroundColor: Colors.black26, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)))).toList())),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _generate, child: const Text('GENERATE'))),
              ],
            ),
          ),
          if (_generatedCommand.isNotEmpty) ...[
            const SizedBox(height: 20),
            MinecraftCard(
              color: const Color(0xFF101010),
              child: Column(
                children: [
                  Text(_generatedCommand, style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace')),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: () { Clipboard.setData(ClipboardData(text: _generatedCommand)); showMinecraftToast(context, 'Copied!'); }, child: const Text('COPY'))),
                      const SizedBox(width: 10),
                      Expanded(child: ElevatedButton(onPressed: _saveCurrent, child: const Text('SAVE'))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavedTab() {
    final filtered = _savedCommands.entries.where((e) => e.key.toLowerCase().contains(_searchController.text.toLowerCase()) || e.value.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'Search saved commands...', prefixIcon: Icon(Icons.search, size: 16), border: OutlineInputBorder()),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final entry = filtered[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MinecraftCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.greenAccent)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.copy, size: 16), onPressed: () { Clipboard.setData(ClipboardData(text: entry.value)); showMinecraftToast(context, 'Copied!'); }),
                        IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.redAccent), onPressed: () { StorageService.deleteCommand(entry.key); _loadSaved(); }),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
