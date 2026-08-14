import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme({required bool largeText, required bool highContrast}) {
    final double scale = largeText ? 1.2 : 1.0;

    // Define colors according to High Contrast preferences
    final Color primaryColor = highContrast ? const Color(0xFF0000CC) : const Color(0xFF2563EB);
    final Color backgroundColor = highContrast ? Colors.white : const Color(0xFFF8FAFC);
    final Color surfaceColor = Colors.white;
    final Color textColor = highContrast ? Colors.black : const Color(0xFF0F172A);
    final Color subTextColor = highContrast ? const Color(0xFF222222) : const Color(0xFF64748B);

    final TextTheme baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: (baseTextTheme.displayLarge?.fontSize ?? 32) * scale,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: (baseTextTheme.displayMedium?.fontSize ?? 28) * scale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22) * scale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: (baseTextTheme.titleMedium?.fontSize ?? 18) * scale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * scale,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * scale,
          fontWeight: FontWeight.normal,
          color: subTextColor,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * scale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: (baseTextTheme.labelSmall?.fontSize ?? 11) * scale,
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
            color: highContrast ? Colors.black : const Color(0xFFDBEAFE),
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
          textStyle: GoogleFonts.inter(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: highContrast ? Colors.black : const Color(0xFFEFF6FF),
        thickness: highContrast ? 2.0 : 1.0,
      ),
    );
  }
}
