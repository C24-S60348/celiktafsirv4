import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeHelper {
  static const String _themeKey = 'selected_theme';

  // Get the current theme name from SharedPreferences
  static Future<String> getThemeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'Terang';
  }

  // Get ThemeData based on theme name
  static ThemeData getThemeData(String themeName) {
    switch (themeName) {
      case 'Gelap':
        return _darkTheme();
      case 'Terang':
      default:
        return _lightTheme();
    }
  }

  // Light brown theme colors (app bar matches buttonlatahzan style)
  static const Color appBarColorLight = Color.fromARGB(255, 230, 215, 196);  // tan/wheat – from buttonlatahzan (light)
  static const Color _brown = Color(0xFF8B7355);            // medium brown (accents)
  static const Color _darkBrown = Color(0xFF5C4033);        // dark brown – app bar (dark)

  /// Loading indicator color: dark brown on light (whitish) background, light on dark.
  static const Color loadingIndicatorDarkBrown = Color(0xFF5C4033);
  static Color getLoadingIndicatorColor(String themeName) {
    return themeName == 'Gelap' ? Colors.white : loadingIndicatorDarkBrown;
  }

  /// The two fonts celiktafsir.net itself uses, so the app reads like the
  /// website. Taken from the site's own stylesheet, not guessed:
  ///
  ///   .wf-active body { font-family: "Arimo", sans-serif }
  ///   .wf-active h1..h6 { font-family: "Alegreya", serif }
  ///
  /// A reader reported the app's font was harder to read than the website's;
  /// the app had no font bundled at all and fell back to the platform default.
  ///
  /// Neither family covers Arabic. That is deliberate and matches the site --
  /// the engine falls back to the platform's Arabic font for those runs.
  static const String bodyFontFamily = 'Arimo';
  static const String headingFontFamily = 'Alegreya';

  /// App bar background color for all screens. Use this when overriding AppBar.backgroundColor.
  static Color getAppBarColor(String themeName) {
    switch (themeName) {
      case 'Gelap':
        return _darkBrown;
      case 'Terang':
      default:
        return appBarColorLight;
    }
  }

  // Light Theme – light brown with black text
  static ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: bodyFontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brown,
        brightness: Brightness.light,
        primary: _brown,
        onPrimary: Colors.white,
        surface: const Color(0xFFF5F0E6),  // warm off-white
        onSurface: Colors.black,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F0E6),
      appBarTheme: const AppBarTheme(
        backgroundColor: appBarColorLight,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: headingFontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black),
        titleSmall: TextStyle(color: Colors.black),
        labelLarge: TextStyle(color: Colors.black),
        labelMedium: TextStyle(color: Colors.black),
        labelSmall: TextStyle(color: Colors.black),
      ),
      cardColor: Colors.white,
      dialogTheme: DialogThemeData(backgroundColor: Colors.white),
    );
  }

  // Dark Theme – brown tint with white text
  static ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: bodyFontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brown,
        brightness: Brightness.dark,
        primary: appBarColorLight,
        surface: const Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBrown,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: headingFontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        elevation: 0,
      ),
      cardColor: const Color(0xFF1E1E1E),
      dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1E1E1E)),
    );
  }

  // Get background color for content areas based on theme
  static Color getContentBackgroundColor(String themeName) {
    switch (themeName) {
      case 'Gelap':
        return const Color(0xFF1E1E1E).withOpacity(0.9);
      case 'Terang':
      default:
        return Colors.white.withOpacity(0.9);
    }
  }

  // Get text color for content areas based on theme
  static Color getTextColor(String themeName) {
    switch (themeName) {
      case 'Gelap':
        return Colors.white;
      case 'Terang':
      default:
        return Colors.black;
    }
  }

  /// Show "Memuat kandungan..." SnackBar using theme color (no purple). Call from baca_* pages.
  static void showMemuatSnackBar(BuildContext context, String themeName) {
    final isDark = themeName == 'Gelap';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Memuat kandungan...',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: getAppBarColor(themeName),
      ),
    );
  }
}

