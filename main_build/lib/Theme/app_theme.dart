import 'package:flutter/material.dart';

@immutable
class CorelyColors extends ThemeExtension<CorelyColors> {
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color accent;
  final Color accentSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color inputFill;
  final Color navigationBar;

  const CorelyColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.accent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.inputFill,
    required this.navigationBar,
  });

  @override
  CorelyColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? border,
    Color? accent,
    Color? accentSoft,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? inputFill,
    Color? navigationBar,
  }) {
    return CorelyColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      inputFill: inputFill ?? this.inputFill,
      navigationBar: navigationBar ?? this.navigationBar,
    );
  }

  @override
  CorelyColors lerp(ThemeExtension<CorelyColors>? other, double t) {
    if (other is! CorelyColors) return this;
    return CorelyColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      navigationBar: Color.lerp(navigationBar, other.navigationBar, t)!,
    );
  }
}

class AppTheme {
  // Main colors
  static const Color accent = Color(0xFFC8FF00);
  static const Color yellow = accent;
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 22);
  static const Color darkSurface = Color(0xFF111116);
  static const Color darkSurfaceRaised = Color(0xFF191B1F);
  static const Color darkBorder = Color(0xFF1E1E24);
  static const Color lightBackground = Color(0xFFF6F7F9);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceRaised = Color(0xFFF1F3F6);
  static const Color lightBorder = Color(0xFFE3E6EA);
  static const Color greyText = Colors.grey;

  static const CorelyColors darkColors = CorelyColors(
    background: darkBackground,
    surface: darkSurface,
    surfaceRaised: darkSurfaceRaised,
    border: darkBorder,
    accent: accent,
    accentSoft: Color(0xFF4A5A00),
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textMuted: Color(0xFF8A8D92),
    inputFill: Color(0xFF0F1115),
    navigationBar: darkSurfaceRaised,
  );

  static const CorelyColors lightColors = CorelyColors(
    background: lightBackground,
    surface: lightSurface,
    surfaceRaised: lightSurfaceRaised,
    border: lightBorder,
    accent: accent,
    accentSoft: Color(0xFFEFFFBB),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF5D6168),
    textMuted: Color(0xFF7C8188),
    inputFill: Color(0xFFF8FAFC),
    navigationBar: Colors.white,
  );

  static ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    palette: darkColors,
  );

  static ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    palette: lightColors,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required CorelyColors palette,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      primaryColor: accent,
      colorScheme: (isDark ? ColorScheme.dark() : ColorScheme.light()).copyWith(
        primary: accent,
        secondary: accent,
        surface: palette.surface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: palette.textPrimary,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: palette.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: palette.textSecondary, fontSize: 14),
        titleLarge: TextStyle(
          color: palette.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(color: palette.textPrimary, fontSize: 16),
        labelMedium: TextStyle(color: palette.textSecondary, fontSize: 14),
      ),
      iconTheme: IconThemeData(color: palette.textPrimary),
      dividerTheme: DividerThemeData(color: palette.border),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.textPrimary,
        unselectedLabelColor: palette.textMuted,
        indicator: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.navigationBar,
        selectedItemColor: accent,
        unselectedItemColor: palette.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: palette.inputFill,
        labelStyle: TextStyle(color: palette.textSecondary),
        hintStyle: TextStyle(color: palette.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        ),
      ),
      extensions: [palette],
    );
  }
}
