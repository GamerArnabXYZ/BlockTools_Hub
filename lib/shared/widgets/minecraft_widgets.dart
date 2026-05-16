import 'package:flutter/material.dart';

/* 
UI v7: MODERN NATIVE WIDGETS
- Material 3 NavigationBar.
- Floating design.
- Animated state switches.
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
    return Container(
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(padding ?? 16.0),
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
  final bool isSliver;

  const MinecraftBasePage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.onRefresh,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            title: Text(title.toUpperCase(), 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            actions: actions,
            floating: true,
            pinned: true,
            snap: true,
          ),
        ],
        body: onRefresh != null
            ? RefreshIndicator(onRefresh: onRefresh!, child: body)
            : body,
      ),
    );
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
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

void showMinecraftToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message.toUpperCase(), 
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
