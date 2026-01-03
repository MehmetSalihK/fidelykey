
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Palette (Cyber-Clean)
  static const Color backgroundDark = Color(0xFF0B1120); // Deep Blue/Black
  static const Color surfaceDark = Color(0xFF1E293B);    // Slate 800
  static const Color surfaceLight = Color(0xFF334155);   // Slate 700 (Inputs)
  static const Color textMain = Colors.white;
  static const Color textSub = Color(0xFF94A3B8);        // Slate 400

  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color accentNeon = Color(0xFF10B981);     // Emerald
  static const Color errorSoft = Color(0xFFEF4444);

  static const double defaultRadius = 20.0;

  // Gradient Brand
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient Surface (Subtle)
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Default Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'Inter', // Default Body Font

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: primaryIndigo,
      secondary: primaryPink,
      surface: surfaceDark,
      background: backgroundDark,
      error: errorSoft,
      onSurface: textMain,
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(color: textMain, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.poppins(color: textMain, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.poppins(color: textMain, fontWeight: FontWeight.w600, fontSize: 20),
      titleMedium: GoogleFonts.poppins(color: textMain, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(color: textMain),
      bodyMedium: GoogleFonts.inter(color: textSub),
      labelLarge: GoogleFonts.poppins(color: textMain, fontWeight: FontWeight.w600),
    ),

    // Component Themes
    cardTheme: CardThemeData(
      color: surfaceDark.withOpacity(0.9),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
      margin: EdgeInsets.zero,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textMain,
      ),
      iconTheme: IconThemeData(color: textMain),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
    ),
    
    // Inputs (Default Fallback)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: const BorderSide(color: primaryIndigo, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: textSub.withOpacity(0.5)),
    ),
  );

  // Light Theme is deprecated in this Cyber-Clean redesign
  static final ThemeData lightTheme = darkTheme; 
}

