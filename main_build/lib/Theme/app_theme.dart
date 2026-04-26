import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// CorelyColors — custom theme extension
// Consumed anywhere via: Theme.of(context).ext
// ─────────────────────────────────────────────
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
  factory CorelyColors.dark() => AppTheme.darkColors;

  factory CorelyColors.light() => AppTheme.lightColors;

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

// ─────────────────────────────────────────────
// Shorthand extension for clean access in widgets
//   final c = context.colors;
//   Container(color: c.surface)
// ─────────────────────────────────────────────
extension CorelyThemeX on BuildContext {
  CorelyColors get colors =>
      Theme.of(this).extension<CorelyColors>() ?? CorelyColors.dark();
}

// ─────────────────────────────────────────────
// AppTheme — Sapphire Neon
// Dark:  deep void-blue blacks + electric-blue accent
// Light: blue-tinted whites with strong borders for clear contrast
// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── Brand accent ─────────────────────────────
  static const Color accent = Color(0xFF2979FF); // vivid sapphire blue
  static const Color accent_2 = Color(0xFF00E5FF); // neon cyan highlight
  static const Color yellow = accent_2; // legacy alias → cyan

  // ── Dark palette raw values ───────────────────
  static const Color darkbackground = Color(0xFF050A18); // near-black cool blue
  static const Color _darkSurface = Color(0xFF0B1225); // dark navy card
  static const Color _darkSurfaceRaised = Color(
    0xFF101B33,
  ); // slightly lifted navy
  static const Color _darkBorder = Color(0xFF1C2E50); // visible navy border
  static const Color _darkInputFill = Color(0xFF070E1F); // deepest fill
  static const Color _darkNavBar = Color(0xFF0B1225);

  // ── Light palette raw values ──────────────────
  // Each step is meaningfully lighter so cards pop from the background.
  static const Color _lightBg = Color(0xFFEDF2FF); // cool blue-white page
  static const Color _lightSurface = Color(0xFFFFFFFF); // pure white cards
  static const Color _lightSurfaceRaised = Color(
    0xFFDDE6FF,
  ); // noticeable blue-grey lift
  static const Color _lightBorder = Color(
    0xFFB0C4F8,
  ); // strong visible blue border
  static const Color _lightInputFill = Color(0xFFF0F4FF); // tinted fill
  static const Color _lightNavBar = Color(0xFFFFFFFF);

  // ── CorelyColors instances ────────────────────
  static const CorelyColors darkColors = CorelyColors(
    background: darkbackground,
    surface: _darkSurface,
    surfaceRaised: _darkSurfaceRaised,
    border: _darkBorder,
    accent: accent,
    accentSoft: Color(0xFF0D2060), // deep navy tint for chips/pills
    textPrimary: Color(0xFFE8F0FF), // cool blue-white
    textSecondary: Color(0xFF8AAAD4), // muted sapphire
    textMuted: Color(0xFF4A6080), // dark slate-blue
    inputFill: _darkInputFill,
    navigationBar: _darkNavBar,
  );

  static const CorelyColors lightColors = CorelyColors(
    background: _lightBg,
    surface: _lightSurface,
    surfaceRaised: _lightSurfaceRaised,
    border: _lightBorder,
    accent: accent,
    accentSoft: Color(0xFFCCDBFF), // pale sapphire — clearly visible on white
    textPrimary: Color(0xFF050A18), // matches dark bg for max contrast
    textSecondary: Color(0xFF3A5280), // readable navy
    textMuted: Color(0xFF7A96BE), // lighter slate
    inputFill: _lightInputFill,
    navigationBar: _lightNavBar,
  );

  // ── Public ThemeData objects ──────────────────
  static ThemeData get darkTheme => _build(Brightness.dark, darkColors);
  static ThemeData get lightTheme => _build(Brightness.light, lightColors);

  // ─────────────────────────────────────────────
  // Builder
  // ─────────────────────────────────────────────
  static ThemeData _build(Brightness brightness, CorelyColors c) {
    final isDark = brightness == Brightness.dark;

    // ColorScheme — use named constructor to avoid deprecation warnings
    final scheme = isDark
        ? ColorScheme.dark(
            primary: accent,
            secondary: accent,
            surface: c.surface,
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: c.textPrimary,
            outline: c.border,
          )
        : ColorScheme.light(
            primary: accent,
            secondary: accent,
            surface: c.surface,
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: c.textPrimary,
            outline: c.border,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      primaryColor: accent,

      // ── Text ───────────────────────────────
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: c.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: TextStyle(
          color: c.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: c.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: c.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: c.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: c.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: c.textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: c.textMuted, fontSize: 12),
        labelLarge: TextStyle(
          color: c.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(color: c.textSecondary, fontSize: 12),
        labelSmall: TextStyle(
          color: c.textMuted,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),

      // ── Icons ──────────────────────────────
      iconTheme: IconThemeData(color: c.textPrimary, size: 22),

      // ── Divider ────────────────────────────
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),

      // ── Cards ──────────────────────────────
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
        ),
      ),

      // ── AppBar ─────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),

      // ── Bottom nav bar ─────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.navigationBar,
        selectedItemColor: accent,
        unselectedItemColor: c.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),

      // ── Tab bar ────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: c.textMuted,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: c.accentSoft,
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // ── Input fields ───────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.inputFill,
        labelStyle: TextStyle(color: c.textSecondary),
        hintStyle: TextStyle(color: c.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),

      // ── Elevated button ────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Text button ────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Outlined button ────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        ),
      ),

      // ── Chip ───────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceRaised,
        labelStyle: TextStyle(color: c.textSecondary, fontSize: 12),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        selectedColor: c.accentSoft,
        secondaryLabelStyle: TextStyle(
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── Switch ─────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : c.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withOpacity(0.4)
              : c.border,
        ),
      ),

      // ── Progress indicator ─────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: c.border,
      ),

      // ── Snack bar ──────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceRaised,
        contentTextStyle: TextStyle(color: c.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Custom extension ───────────────────
      extensions: [c],
    );
  }
}
