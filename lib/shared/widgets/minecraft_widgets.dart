import 'package:flutter/material.dart';

/* 
MINECRAFT UI SYSTEM - v3 POLISH:
- Added Loading Skeletons.
- Added Minecraft-style Toast.
- Improved spacing and borders.
*/

class MinecraftCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double? padding;

  const MinecraftCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? const Color(0xFF313131),
          border: Border.all(color: const Color(0xFF000000), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(4, 4),
              blurRadius: 0,
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding ?? 12.0),
          child: child,
        ),
      ),
    );
  }
}

class MinecraftBasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const MinecraftBasePage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(title.toUpperCase(), 
          style: const TextStyle(fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        centerTitle: true,
        actions: actions,
      ),
      body: RepaintBoundary(
        child: body,
      ),
    );
  }
}

/* Skeleton loader for smoother transitions */
class MinecraftSkeleton extends StatelessWidget {
  final double height;
  final double width;

  const MinecraftSkeleton({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white10,
        border: Border.all(color: Colors.black, width: 2),
      ),
    );
  }
}

/* Simple Feedback Toast */
void showMinecraftToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message.toUpperCase(), 
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF3C8527),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
  );
}
