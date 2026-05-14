import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';

/* 
COMMAND GEN v2:
- Presets Library.
- Improved feedback.
- Category-specific inputs.
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
  String _generatedCommand = '';

  final Map<String, List<String>> _presets = {
    'Give Item': ['diamond', 'netherite_ingot', 'golden_apple', 'elytra'],
    'Teleport': ['@p', '@a', '@r', '@e'],
    'Summon': ['zombie', 'creeper', 'ender_dragon', 'tnt'],
    'Effect': ['speed', 'strength', 'regeneration', 'night_vision'],
  };

  void _generate() {
    String cmd = '';
    final target = _targetController.text.trim();
    final item = _itemController.text.trim();
    
    switch (_selectedCategory) {
      case 'Give Item':
        cmd = '/give $target minecraft:$item ${_countController.text.trim()}';
        break;
      case 'Teleport':
        cmd = '/tp $target ~ ~ ~';
        break;
      case 'Summon':
        cmd = '/summon minecraft:$item ~ ~ ~';
        break;
      case 'Effect':
        cmd = '/effect give $target minecraft:$item 30 1';
        break;
    }

    setState(() {
      _generatedCommand = cmd;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Command Builder v2',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: const Color(0xFF313131),
                    items: _presets.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() {
                      _selectedCategory = val!;
                      _itemController.text = _presets[val]!.first;
                    }),
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _targetController,
                    decoration: const InputDecoration(labelText: 'Target', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(labelText: 'ID / Name', border: OutlineInputBorder()),
                  ),
                  
                  /* Preset Suggestions */
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('PRESETS:', style: TextStyle(fontSize: 8, color: Colors.white54)),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _presets[_selectedCategory]!.map((p) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(p, style: const TextStyle(fontSize: 10)),
                          onPressed: () => setState(() => _itemController.text = p),
                          backgroundColor: Colors.black26,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                      )).toList(),
                    ),
                  ),

                  if (_selectedCategory == 'Give Item') ...[
                    const SizedBox(height: 15),
                    TextField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Count', border: OutlineInputBorder()),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _generate, child: const Text('BUILD COMMAND')),
                  ),
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
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedCommand));
                        showMinecraftToast(context, 'Command Copied!');
                      },
                      child: const Text('COPY TO CLIPBOARD'),
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
