import 'package:flutter/material.dart';

/* 
LAG FIX: 
- Custom font families (monospace) hata di gayi hain performance ke liye.
- Theme ko extreme lightweight rakha gaya hai.
*/
class AppTheme {
  static const Color minecraftDark = Color(0xFF1E1E1E);
  static const Color minecraftGreen = Color(0xFF3C8527);
  static const Color minecraftGrey = Color(0xFF313131);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: minecraftGreen,
      scaffoldBackgroundColor: minecraftDark,
      // Default system font use karenge performance ke liye
      cardColor: minecraftGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF101010),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: minecraftGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
    );
  }
}
