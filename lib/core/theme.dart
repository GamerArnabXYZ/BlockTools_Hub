import 'package:flutter/material.dart';

/* Ye class app ke Minecraft-inspired theme ko handle karti hai */
class AppTheme {
  static const Color minecraftDark = Color(0xFF1E1E1E);
  static const Color minecraftGreen = Color(0xFF3C8527);
  static const Color minecraftGrey = Color(0xFF313131);
  static const Color minecraftLightGrey = Color(0xFF8B8B8B);
  static const Color minecraftBorderDark = Color(0xFF000000);
  static const Color minecraftBorderLight = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: minecraftGreen,
      scaffoldBackgroundColor: minecraftDark,
      fontFamily: 'monospace', // Pixel feel ke liye monospace use kar rahe hain
      cardColor: minecraftGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF101010),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: Colors.white,
          fontFamily: 'monospace',
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'monospace', color: Colors.white),
        bodyMedium: TextStyle(fontFamily: 'monospace', color: Colors.white70),
        titleLarge: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: minecraftGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
    );
  }
}
