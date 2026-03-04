import 'package:flutter/material.dart';
import 'theme_extension.dart';

class AppTheme {
  // Blue palette from icon
  static const Color primaryBright = Color(0xFF49A4FF);
  static const Color brandMain = Color(0xFF007FFF);
  static const Color darkBase = Color(0xFF004589);
  static const Color accentHighlight = Color(0xFFD8EBFF);
  static const Color backgroundDark = Color(0xFF001E3B);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: brandMain,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: brandMain,
      secondary: primaryBright,
      surface: Colors.white,
      background: Colors.white,
      error: Colors.redAccent,
    ),
    extensions: [
      KiniteThemeExtension(
        glassColor: Colors.white.withOpacity(0.3),
        glassBorder: accentHighlight.withOpacity(0.3),
        primaryGradient: const LinearGradient(
          colors: [primaryBright, brandMain],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        buttonShadow: primaryBright.withOpacity(0.3),
      ),
    ],
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    // cardTheme removed – we use custom GlassCard instead
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: brandMain,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: brandMain,
      secondary: primaryBright,
      surface: Color(0xFF0A2A44),
      background: backgroundDark,
      error: Colors.redAccent,
    ),
    extensions: [
      KiniteThemeExtension(
        glassColor: accentHighlight.withOpacity(0.1),
        glassBorder: accentHighlight.withOpacity(0.2),
        primaryGradient: const LinearGradient(
          colors: [primaryBright, brandMain],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        buttonShadow: primaryBright.withOpacity(0.5),
      ),
    ],
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    // cardTheme removed
  );
}