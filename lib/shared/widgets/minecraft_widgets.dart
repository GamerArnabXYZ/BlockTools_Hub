import 'package:flutter/material.dart';

/* 
ULTRA PERFORMANCE OPTIMIZATION (LAG FIX):
- MinecraftCard ko simplify kiya gaya hai. Multi-border rendering HTML renderer pe heavy hota hai.
- InkWell ko remove karke GestureDetector use kiya hai (lightweight).
- Decoration ko minimal rakha hai taaki repaint fast ho.
*/
class MinecraftCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  const MinecraftCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Solid borders are much faster than individual BorderSide objects
        decoration: BoxDecoration(
          color: color ?? const Color(0xFF313131),
          border: Border.all(color: const Color(0xFF000000), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}

class MinecraftBasePage extends StatelessWidget {
  final String title;
  final Widget body;

  const MinecraftBasePage({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(title.toUpperCase(), style: const TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        centerTitle: true,
      ),
      /* RepaintBoundary zaroori hai performance ke liye */
      body: RepaintBoundary(
        child: body,
      ),
    );
  }
}
