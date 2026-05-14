import 'package:flutter/material.dart';

/* 
DEEP PERFORMANCE OPTIMIZATION: 
- Transparency (Opacity) hata di gayi hai kyunki HTML renderer pe ye laggy hota hai.
- Box Decoration ko simplify kiya gaya hai.
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
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? const Color(0xFF313131),
          border: const Border(
            top: BorderSide(color: Color(0xFF707070), width: 3),
            left: BorderSide(color: Color(0xFF707070), width: 3),
            right: BorderSide(color: Color(0xFF000000), width: 3),
            bottom: BorderSide(color: Color(0xFF000000), width: 3),
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
        title: Text(title.toUpperCase()),
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
      ),
      /* RepaintBoundary use kiya hai taaki UI sections independent render ho */
      body: RepaintBoundary(
        child: body,
      ),
    );
  }
}
