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
    primaryColor: yellow,
    colorScheme: ColorScheme.dark(primary: yellow, surface: darkSurface),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
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
    primaryColor: yellow,
    colorScheme: ColorScheme.light(primary: yellow, surface: lightBackground),
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
