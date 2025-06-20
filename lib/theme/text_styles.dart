import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle title(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.montserrat(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.montserrat(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black,
    );
  }

  static TextStyle body(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GoogleFonts.montserrat(
      fontSize: 14,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle bodyBold(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    );
  }

  static TextStyle caption(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GoogleFonts.montserrat(
      fontSize: 12,
      color: colorScheme.onSurface.withValues(alpha: 0.8),
    );
  }

  static TextStyle button(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black,
    );
  }

  static TextStyle input(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.montserrat(
      fontSize: 14,
      color: isDark ? Colors.white : Colors.black,
    );
  }

  static TextStyle inputHint(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.montserrat(
      fontSize: 14,
      color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
    );
  }

  static TextStyle error(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GoogleFonts.montserrat(
      fontSize: 12,
      color: colorScheme.error,
    );
  }

  static TextStyle success(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GoogleFonts.montserrat(
      fontSize: 12,
      color: colorScheme.primary,
    );
  }

  static TextStyle value(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: colorScheme.primary,
    );
  }

  static TextStyle label(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isDark ? Colors.white : Colors.black,
    );
  }
} 