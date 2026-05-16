import 'package:flutter/material.dart';
import 'package:blocktools_hub/core/theme.dart';
import 'package:blocktools_hub/core/services/storage_service.dart';
import 'package:blocktools_hub/features/navigation/presentation/main_screen.dart';

void main() async {
  /* App start yahan se hota hai */
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init(); 
  runApp(const BlockToolsHub());
}

class BlockToolsHub extends StatelessWidget {
  const BlockToolsHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockTools Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      /* Ab hum MainScreen (Bottom Nav) se start karenge */
      home: const MainScreen(),
    );
  }
}
