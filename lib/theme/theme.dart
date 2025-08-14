import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts for consistent typography

// ---------------------------------------------
// COLOR CONSTANTS
// ---------------------------------------------
final Color darkPrimary =
    const Color(0xFF222831); // Deep grey-blue for dark mode
final Color lightPrimary =
    const Color(0xFF5C5470); // Subtle violet for light mode

// ---------------------------------------------
// LIGHT THEME CONFIGURATION
// ---------------------------------------------
final ThemeData appLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: lightPrimary,
  scaffoldBackgroundColor: Colors.grey[100],
  cardColor: Colors.white,
  dividerColor: Colors.grey[300],
  iconTheme: const IconThemeData(color: Colors.black87),

  // Typography using Poppins
  textTheme: GoogleFonts.poppinsTextTheme(
    const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
  ),

  // AppBar styling
  appBarTheme: AppBarTheme(
    backgroundColor: lightPrimary,
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),

  // Button styling
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: lightPrimary,
    foregroundColor: Colors.white,
  ),

  chipTheme: ChipThemeData(
    backgroundColor: lightPrimary.withValues(alpha: 0.1),
    labelStyle: const TextStyle(color: Colors.black),
    secondaryLabelStyle: const TextStyle(color: Colors.black),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
);

// ---------------------------------------------
// DARK THEME CONFIGURATION
// ---------------------------------------------
final ThemeData appDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: darkPrimary,
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: Colors.white24,
  iconTheme: const IconThemeData(color: Colors.white70),
  textTheme: GoogleFonts.poppinsTextTheme(
    ThemeData.dark().textTheme.copyWith(
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: darkPrimary,
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkPrimary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: darkPrimary,
    foregroundColor: Colors.white,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white12,
    labelStyle: const TextStyle(color: Colors.white),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
);
