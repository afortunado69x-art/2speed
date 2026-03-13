import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrimTheme {
  // ── Palette ──────────────────────────────────────────────
  static const Color black      = Color(0xFF080608);
  static const Color void_      = Color(0xFF0D0A0F);
  static const Color deep       = Color(0xFF120E16);
  static const Color shadow_    = Color(0xFF1A1320);
  static const Color stone      = Color(0xFF221929);
  static const Color ash        = Color(0xFF2E2238);
  static const Color smoke      = Color(0xFF3D3150);
  static const Color mist       = Color(0xFF54436A);
  static const Color dust       = Color(0xFF7A6892);
  static const Color pale       = Color(0xFFA89CBD);
  static const Color bone       = Color(0xFFD4C8E0);
  static const Color parchment  = Color(0xFFE8DFC8);

  static const Color blood      = Color(0xFF8B1A1A);
  static const Color crimson    = Color(0xFFB22020);
  static const Color scarlet    = Color(0xFFCC3030);
  static const Color ember      = Color(0xFFD4541A);

  static const Color gold       = Color(0xFFC8A040);
  static const Color tarnished  = Color(0xFF8A6C28);
  static const Color copper_    = Color(0xFFA07030);

  static const Color sage       = Color(0xFF3A5040);
  static const Color verdigris  = Color(0xFF4A7060);

  // ── Book spine colors ─────────────────────────────────────
  static const List<Color> bookColors = [
    Color(0xFF5A0F0F), // crimson
    Color(0xFF0A1A3A), // navy
    Color(0xFF0D2B1A), // forest
    Color(0xFF2A0F35), // plum
    Color(0xFF2A1F08), // tarnish
    Color(0xFF1A1820), // slate
    Color(0xFF2A1408), // brown
  ];

  // ── Typography via google_fonts (no local font files needed) ─
  //
  // UnifrakturMaguntia → gothic logo/rune display
  // Cinzel Decorative  → section headings
  // Cinzel             → UI labels, nav, caps
  // IM Fell English    → body text, reader content

  static TextStyle runeFont({double size = 32, Color? color}) =>
    GoogleFonts.unifrakturMaguntia(
      fontSize: size,
      color: color ?? gold,
      letterSpacing: 2.0,
    );

  static TextStyle cinzelDeco({
    double size = 18,
    FontWeight weight = FontWeight.normal,
    Color? color,
  }) =>
    GoogleFonts.cinzelDecorative(
      fontSize: size,
      fontWeight: weight,
      color: color ?? bone,
    );

  static TextStyle cinzel({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    Color? color,
    double spacing = 0.5,
  }) =>
    GoogleFonts.cinzel(
      fontSize: size,
      fontWeight: weight,
      color: color ?? bone,
      letterSpacing: spacing,
    );

  static TextStyle fell({
    double size = 14,
    bool italic = false,
    Color? color,
  }) =>
    GoogleFonts.imFellEnglish(
      fontSize: size,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      color: color ?? bone,
    );

  // ── ThemeData ─────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: void_,
    colorScheme: const ColorScheme.dark(
      primary:    gold,
      secondary:  crimson,
      surface:    deep,
      error:      scarlet,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: black,
      elevation: 0,
      titleTextStyle: cinzelDeco(size: 20),
      iconTheme: const IconThemeData(color: gold),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: black,
      selectedItemColor: gold,
      unselectedItemColor: mist,
      selectedLabelStyle: cinzel(size: 8, spacing: 1.5),
      unselectedLabelStyle: cinzel(size: 8, spacing: 1.5),
      type: BottomNavigationBarType.fixed,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: gold,
      inactiveTrackColor: ash,
      thumbColor: gold,
      overlayColor: gold.withOpacity(0.15),
      trackHeight: 2,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? scarlet : dust),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
          ? blood.withOpacity(0.5) : ash),
    ),
    dividerColor: gold.withOpacity(0.12),
    useMaterial3: true,
  );
}
