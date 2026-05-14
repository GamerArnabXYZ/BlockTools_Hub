import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blocktools_hub/shared/widgets/minecraft_widgets.dart';

/* Command Generator jo basic templates use karke command strings banata hai */
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

  final List<String> _categories = ['Give Item', 'Teleport', 'Summon', 'Effect'];

  /* Command generate karne ka logic */
  void _generate() {
    String cmd = '';
    final target = _targetController.text.trim();
    
    switch (_selectedCategory) {
      case 'Give Item':
        cmd = '/give $target ${_itemController.text.trim()} ${_countController.text.trim()}';
        break;
      case 'Teleport':
        cmd = '/tp $target ~ ~ ~';
        break;
      case 'Summon':
        cmd = '/summon ${_itemController.text.trim()} ~ ~ ~';
        break;
      case 'Effect':
        cmd = '/effect give $target ${_itemController.text.trim()} 30 1';
        break;
    }

    setState(() {
      _generatedCommand = cmd;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MinecraftBasePage(
      title: 'Command Gen',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MinecraftCard(
              child: Column(
                children: [
                  const Text('COMMAND SETTINGS', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _targetController,
                    decoration: const InputDecoration(labelText: 'Target (@p, @a, Username)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _itemController,
                    decoration: InputDecoration(
                      labelText: (_selectedCategory == 'Give Item' || _selectedCategory == 'Summon' || _selectedCategory == 'Effect') 
                        ? 'Item/Entity/Effect ID' : 'N/A', 
                      border: const OutlineInputBorder()
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
                    child: ElevatedButton(onPressed: _generate, child: const Text('GENERATE')),
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
                    const Text('RESULT:', style: TextStyle(fontSize: 10, color: Colors.white54)),
                    const SizedBox(height: 10),
                    Text(_generatedCommand, style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedCommand));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Command Copied!')));
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('COPY TO CLIPBOARD'),
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
