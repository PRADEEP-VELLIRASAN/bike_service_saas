import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shadcn-inspired theme configuration
/// Clean, minimal design with subtle borders and modern typography
class AppTheme {
  // Neutral Colors (Shadcn-style)
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF0F172A);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF0F172A);
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color input = Color(0xFFE2E8F0);
  
  // Primary Colors
  static const Color primary = Color(0xFF0F172A);
  static const Color primaryForeground = Color(0xFFF8FAFC);
  
  // Secondary
  static const Color secondary = Color(0xFFF1F5F9);
  static const Color secondaryForeground = Color(0xFF0F172A);
  
  // Accent Colors
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentForeground = Color(0xFFFFFFFF);
  
  // Destructive
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Ring/Focus
  static const Color ring = Color(0xFF0F172A);
  
  // Radius
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: card,
      error: destructive,
      onPrimary: primaryForeground,
      onSecondary: secondaryForeground,
      onSurface: foreground,
      onError: destructiveForeground,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: foreground,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: foreground,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: foreground,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: foreground,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: foreground,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: mutedForeground,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: mutedForeground,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: background,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: border),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: primaryForeground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        side: const BorderSide(color: input),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: input),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: input),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: ring, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: destructive),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: mutedForeground,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: mutedForeground,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: foreground,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: primaryForeground,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: background,
      selectedItemColor: primary,
      unselectedItemColor: mutedForeground,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: muted,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: foreground);
        }
        return GoogleFonts.inter(fontSize: 12, color: mutedForeground);
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: secondary,
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSm),
      ),
      side: BorderSide.none,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: card,
      collapsedBackgroundColor: card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: border),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: border),
      ),
    ),
  );
  
  // Helper method for status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warning;
      case 'confirmed':
        return info;
      case 'in progress':
        return accent;
      case 'ready for delivery':
        return success;
      case 'completed':
        return const Color(0xFF16A34A);
      case 'cancelled':
        return destructive;
      default:
        return mutedForeground;
    }
  }
}
