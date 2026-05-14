import 'package:flutter/material.dart';

/* Custom card widget jo Minecraft block jaisa dikhta hai */
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
        decoration: BoxDecoration(
          color: color ?? const Color(0xFF313131),
          border: const Border(
            top: BorderSide(color: Color(0xFF8B8B8B), width: 4),
            left: BorderSide(color: Color(0xFF8B8B8B), width: 4),
            right: BorderSide(color: Color(0xFF000000), width: 4),
            bottom: BorderSide(color: Color(0xFF000000), width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}

/* Base page widget common layout ke liye */
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
      appBar: AppBar(
        title: Text(title.toUpperCase()),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://www.transparenttextures.com/patterns/dark-matter.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.1,
          ),
        ),
        child: body,
      ),
    );
  }
}
