import 'package:flutter/material.dart';

/* 
MINECRAFT UI SYSTEM - v6 MOBILE OVERHAUL:
- Improved spacing for mobile thumb access.
- Standard mobile app patterns (AppBar consistency).
- Refresh support.
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: Container(
          decoration: BoxDecoration(
            color: color ?? const Color(0xFF313131),
            border: Border.all(color: const Color(0xFF000000), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(2, 2),
                blurRadius: 0,
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(padding ?? 12.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

class MinecraftBasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;

  const MinecraftBasePage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: const Color(0xFF121212), // Deeper dark for native feel
      appBar: AppBar(
        title: Text(title.toUpperCase(), 
          style: const TextStyle(fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        centerTitle: false, // Align left for Android style
        actions: actions,
      ),
      body: RepaintBoundary(
        child: body,
      ),
    );

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        backgroundColor: const Color(0xFF313131),
        color: Colors.greenAccent,
        child: content,
      );
    }

    return content;
  }
}

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
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }
}

void showMinecraftToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message.toUpperCase(), 
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded toast
    ),
  );
}
