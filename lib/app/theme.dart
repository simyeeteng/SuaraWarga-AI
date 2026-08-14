import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme({required bool largeText, required bool highContrast}) {
    final double scale = largeText ? 1.2 : 1.0;

    // Defined from UI-UX-Pro-Max & Frontend-Design synthesis
    final Color primaryColor = highContrast ? const Color(0xFF0000CC) : const Color(0xFF1E40AF);
    final Color backgroundColor = highContrast ? Colors.white : const Color(0xFFEFF6FF);
    const Color surfaceColor = Colors.white;
    final Color textColor = highContrast ? Colors.black : const Color(0xFF1E3A8A);
    final Color subTextColor = highContrast ? const Color(0xFF222222) : const Color(0xFF475569);
    final Color borderColor = highContrast ? Colors.black : const Color(0xFFBFDBFE);

    final TextTheme baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: const Color(0xFF16A34A),
        tertiary: const Color(0xFFD97706),
        background: backgroundColor,
        surface: surfaceColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32 * scale,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28 * scale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22 * scale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18 * scale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14 * scale,
          fontWeight: FontWeight.normal,
          color: subTextColor,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14 * scale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 11 * scale,
          fontWeight: FontWeight.bold,
          color: subTextColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: borderColor,
            width: highContrast ? 2.5 : 1.0,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: highContrast ? const BorderSide(color: Colors.black, width: 2.0) : BorderSide.none,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: highContrast ? 2.0 : 1.0,
      ),
    );
  }
}
