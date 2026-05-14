import 'package:flutter/material.dart';

/* Ye class app ke Minecraft-inspired theme ko handle karti hai */
class AppTheme {
  static const Color minecraftDark = Color(0xFF1E1E1E);
  static const Color minecraftGreen = Color(0xFF3C8527);
  static const Color minecraftGrey = Color(0xFF313131);
  static const Color minecraftAccent = Color(0xFF00AA00);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: minecraftGreen,
      scaffoldBackgroundColor: minecraftDark,
      cardColor: minecraftGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: minecraftDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: minecraftGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Blocky look
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: minecraftGrey,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Minecraft style corners
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}
