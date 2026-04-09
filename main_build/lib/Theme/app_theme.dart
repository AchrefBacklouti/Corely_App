import 'package:flutter/material.dart';

class AppTheme {
  // Main colors
  static const Color yellow = Color(0xFFFFD600);
  static const Color darkBackground = Color.fromARGB(229, 13, 17, 23);
  static const Color darkSurface = Color(0xFF101318);
  static const Color lightBackground = Colors.white;
  static const Color greyText = Colors.grey;

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    canvasColor: darkBackground,
    primaryColor: yellow,
    colorScheme: ColorScheme.dark(
      primary: yellow,
      surface: darkBackground,
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white70,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: TextStyle(color: Colors.white, fontSize: 16),
      labelMedium: TextStyle(color: Colors.white70, fontSize: 14),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerTheme: const DividerThemeData(color: Colors.white24),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: yellow,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    canvasColor: lightBackground,
    primaryColor: yellow,
    colorScheme: ColorScheme.light(
      primary: yellow,
      surface: lightBackground,
      onSurface: Colors.black,
      onSurfaceVariant: Colors.black54,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: TextStyle(color: Colors.black, fontSize: 16),
      labelMedium: TextStyle(color: Colors.black54, fontSize: 14),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    dividerTheme: const DividerThemeData(color: Colors.black26),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: yellow,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
      ),
    ),
  );
}
