import 'package:flutter/material.dart';
import 'package:blocktools_hub/core/theme.dart';
import 'package:blocktools_hub/features/home/presentation/pages/home_page.dart';

void main() {
  /* App start yahan se hota hai */
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
      /* Home page ko initial screen set kiya hai */
      home: const HomePage(),
    );
  }
}
