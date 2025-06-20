import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const double _borderWidth = 1.0;
  static const Color _borderColor = Colors.white;

  // Couleurs
  static Color primaryRed = const Color(0xFFE63946);
  static Color black = Colors.black;
  static Color white = Colors.white;
  static Color grey = const Color(0xFFF5F5F5);

  static final cardTheme = CardThemeData(
    color: grey,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: _borderColor, width: _borderWidth),
    ),
  );

  static final listTileTheme = ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: _borderColor, width: _borderWidth),
    ),
  );

  static final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryRed,
      foregroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _borderColor, width: _borderWidth),
      ),
    ),
  );

  static final appBarTheme = AppBarTheme(
    backgroundColor: primaryRed,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: GoogleFonts.montserrat(
      color: white,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
    shape: const Border(
      bottom: BorderSide(color: _borderColor, width: _borderWidth),
    ),
  );

  static final floatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: primaryRed,
    foregroundColor: white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: _borderColor, width: _borderWidth),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: primaryRed,
          secondary: primaryRed,
          surface: white,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.montserrat(color: black),
          displayMedium: GoogleFonts.montserrat(color: black),
          displaySmall: GoogleFonts.montserrat(color: black),
          headlineLarge: GoogleFonts.montserrat(color: black),
          headlineMedium: GoogleFonts.montserrat(color: black),
          headlineSmall: GoogleFonts.montserrat(color: black),
          titleLarge: GoogleFonts.montserrat(color: black),
          titleMedium: GoogleFonts.montserrat(color: black),
          titleSmall: GoogleFonts.montserrat(color: black),
          bodyLarge: GoogleFonts.montserrat(color: black),
          bodyMedium: GoogleFonts.montserrat(color: black),
        ),
        cardTheme: cardTheme,
        listTileTheme: listTileTheme,
        elevatedButtonTheme: elevatedButtonTheme,
        appBarTheme: appBarTheme,
        floatingActionButtonTheme: floatingActionButtonTheme,
        scaffoldBackgroundColor: white,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: primaryRed,
          secondary: primaryRed,
          surface: const Color(0xFF232323),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.montserrat(color: white),
          displayMedium: GoogleFonts.montserrat(color: white),
          displaySmall: GoogleFonts.montserrat(color: white),
          headlineLarge: GoogleFonts.montserrat(color: white),
          headlineMedium: GoogleFonts.montserrat(color: white),
          headlineSmall: GoogleFonts.montserrat(color: white),
          titleLarge: GoogleFonts.montserrat(color: white),
          titleMedium: GoogleFonts.montserrat(color: white),
          titleSmall: GoogleFonts.montserrat(color: white),
          bodyLarge: GoogleFonts.montserrat(color: white),
          bodyMedium: GoogleFonts.montserrat(color: white),
        ),
        cardTheme: cardTheme.copyWith(
          color: const Color(0xFF232323),
        ),
        listTileTheme: listTileTheme,
        elevatedButtonTheme: elevatedButtonTheme,
        appBarTheme: appBarTheme,
        floatingActionButtonTheme: floatingActionButtonTheme,
        scaffoldBackgroundColor: const Color(0xFF121212),
      );
} 